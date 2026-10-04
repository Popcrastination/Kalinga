-- Kalinga schema. Run this once in your Supabase project's SQL editor
-- (Dashboard → SQL Editor → New query) before running the app.
-- Matches the tables described in docs/01-proposal.md.

-- ── profiles ────────────────────────────────────────────────────────────
-- id matches auth.users.id — created by AuthService right after sign-up,
-- not by a trigger, so a failed profile insert is visible as an error
-- rather than silently missing.
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique,
  first_name text not null,
  last_name text not null,
  date_of_birth text not null, -- stored as typed, e.g. "05/14/2003"
  height_cm numeric not null,
  weight_kg numeric not null,
  join_date timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "profiles: read own" on profiles
  for select using (auth.uid() = id);
create policy "profiles: update own" on profiles
  for update using (auth.uid() = id);
create policy "profiles: insert own" on profiles
  for insert with check (auth.uid() = id);

-- ── food_logs ───────────────────────────────────────────────────────────
create table if not exists food_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_type text not null check (meal_type in ('breakfast', 'lunch', 'dinner')),
  description text not null,
  gemini_validated boolean not null default false,
  logged_at timestamptz not null default now()
);

alter table food_logs enable row level security;

create policy "food_logs: owner only" on food_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── drink_logs ──────────────────────────────────────────────────────────
create table if not exists drink_logs (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  description text not null,
  amount_ml numeric, -- nullable: the UI doesn't always collect a quantity
  gemini_validated boolean not null default false,
  logged_at timestamptz not null default now()
);

alter table drink_logs enable row level security;

create policy "drink_logs: owner only" on drink_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── sleep_records ───────────────────────────────────────────────────────
-- One row per user per day: re-logging Sleep the same day updates it
-- (see LogService.upsertSleepRecord), so the unique constraint matters.
create table if not exists sleep_records (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  duration_hours numeric not null check (duration_hours >= 0 and duration_hours <= 24),
  date date not null,
  unique (user_id, date)
);

alter table sleep_records enable row level security;

create policy "sleep_records: owner only" on sleep_records
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── exercise_records ────────────────────────────────────────────────────
create table if not exists exercise_records (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  duration_minutes numeric not null check (duration_minutes >= 0),
  date date not null,
  unique (user_id, date)
);

alter table exercise_records enable row level security;

create policy "exercise_records: owner only" on exercise_records
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- ── health_analysis ─────────────────────────────────────────────────────
-- One row per user per day — the cached Gemini output. See
-- lib/services/analysis_service.dart: this is what stops the app from
-- calling Gemini more than once a day per user.
create table if not exists health_analysis (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  wellness_score integer not null check (wellness_score >= 0 and wellness_score <= 100),
  daily_summary_text text not null,
  weekly_trend_json jsonb not null,
  suggestions_text jsonb not null,
  analysis_date date not null,
  unique (user_id, analysis_date)
);

alter table health_analysis enable row level security;

create policy "health_analysis: owner only" on health_analysis
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
