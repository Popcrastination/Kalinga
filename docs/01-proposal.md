# Proposal

## The problem, in one sentence
People often forget to monitor their health and lose track of daily habits —
particularly sugar, salt, water, sleep, and activity — because tracking is
scattered across memory, paper, or disconnected apps; I've experienced this
myself using Samsung Notes and consistently failing to keep it updated.

## Who it is for
Students and busy young adults who want to build healthier habits but
currently rely on memory, scattered notes, or nothing at all — including
myself, someone who eats out often and loses track of water and sleep
consistency because there's no single place logging it automatically.

## Core features
1. **Login / Register** — account creation and sign-in (username, name, DOB,
   height, weight, password).
2. **Dashboard** — today's wellness score, Today's Progress chips, weekly
   sleep chart, a Gemini-generated Quick Insight.
3. **Daily Log** — log meals and drinks (validated as food/drink by the
   Gemini API), sleep duration (0–24 hrs), exercise duration (minutes).
4. **Overview** — Gemini-generated Daily Summary, Weekly Summary trend
   percentages (sleep/water/activity), and suggestions.
5. **Profile** — view/edit age, height, weight, and goals; log out.

## Out of scope, and why
- **Cross-device sync as the reason for the backend** — the app doesn't
  strictly need it (single device is enough for this term); Supabase was
  chosen for auth-security and SQL-practice reasons instead, not for sync.
- **Profile picture upload** — stretch goal; ships with a placeholder avatar
  for now.
- **Charts beyond the weekly sleep line** (water/activity trend charts) —
  stretch goal.
- **Push notifications, offline sync, PDF export** — not part of this
  project; Gemini API integration is the one "extra" feature being built,
  and it's treated as core rather than adding more on top of it.

## Data the app remembers, and where it is saved
Stored in **Supabase (Postgres)**, chosen because the data is relational and
dated (needs date-range queries for weekly charts/summaries) and because the
app has real login/password accounts, so offloading auth security to a
managed service is safer than hand-rolling it. Tradeoff: the app now needs
internet access for login and logging; it's not offline-capable.

| Table | Fields |
|---|---|
| `profiles` | id (FK to auth.users), username, first_name, last_name, date_of_birth, height_cm, weight_kg, join_date |
| `food_logs` | id, user_id, meal_type, description, gemini_validated, logged_at |
| `drink_logs` | id, user_id, description, amount_ml, gemini_validated, logged_at |
| `sleep_records` | id, user_id, duration_hours, date |
| `exercise_records` | id, user_id, duration_minutes, date |
| `health_analysis` | id, user_id, wellness_score, daily_summary_text, weekly_trend_json, suggestions_text, analysis_date |

Row Level Security restricts every table so a user can only read/write rows
where `user_id` matches their own authenticated id.

## Risks
1. **Gemini API integration** — specifically: structuring prompts so the
   model gives consistent, sensible validation/suggestions rather than
   generic text, and handling a failed or slow response gracefully in Daily
   Log and Overview. *First step: build a minimal prompt + error-handling
   spike before wiring it into the real screens.*
2. **Wellness-score and weekly-trend computation** — this is custom math
   (turning raw logs into a 0–100 score and ↑/↓/→ trend indicators), not
   something a package provides, so the exact formula still needs to be
   designed. *First step: sketch the formula on paper against a week of
   sample data before writing it in Dart.*
3. **Never shipping the Gemini key in the web build** — a Gemini key is
   billable and must not be compiled into a client build (see
   `docs/06-security-and-privacy.md`); Daily Log's Gemini calls will need a
   small proxy (e.g. a Supabase Edge Function) rather than calling the
   Gemini API directly from Flutter web.

## Changes since the last version
- **2026 — storage decision added:** chose Supabase over local `sqflite`,
  even though the app doesn't need cross-device sync, because the mockup has
  real login/password accounts (auth security) and to deliberately practice
  SQL/Postgres.
- **2026 — screens went from 4 to 6:** the original plan (Dashboard, Health
  Logging, Summary, Profile) didn't include Login/Register; building the
  Figma mockup showed account creation needed to be explicit, and "Health
  Logging"/"Summary" became "Daily Log"/"Overview" once every field was
  mapped out.
- **2026 — Login, Register, and Dashboard built:** see `lib/screens/`. First
  real Flutter/widget experience — hours and widget names to be logged in
  `docs/04-weekly-reports.md` as the term progresses.
