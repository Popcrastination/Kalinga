# AI usage

This project was built with AI assistance. This file is the record of it. It is
graded as the finals badge, and it is worth 100 points.

Start it in week 1 and keep it up as you go. The commit history of this file is
part of the evidence: a file written all at once the night before the deadline
looks exactly like what it is.

## 1. How I used AI

At least six entries. One per real use. Every entry needs a commit link.

### 2026-09-05 - Revised the prelim proposal with a real storage decision

- **Tool:** Claude (Sonnet)
- **What I asked for:** help revising the prelim app proposal now that Flutter
  screens had been built, including a storage decision (Supabase vs.
  alternatives).
- **What it gave back:** a revised proposal document, and later a
  recommendation to use Supabase over local `sqflite`, reasoned from the
  app's actual needs (relational, dated logs needing range queries; real
  login/password accounts needing proper auth security) rather than
  popularity.
- **What I kept, what I changed, and why:** I kept what AI suggest to me
  on revising my proposal since from my own work I've seen it so
  vague and not complete.
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/3c1dd067d03265b77aa5ad859df566caec695186

### 2026-09-23 - Built the first three screens (Login, Register, Dashboard)

- **Tool:** Claude (Sonnet)
- **What I asked for:** full Flutter code for Login, Register, and Dashboard,
  using the design system's components, with comments marking where
  state management and API calls would go later.
- **What it gave back:** `lib/screens/login_page.dart`, `register_page.dart`,
  `dashboard_page.dart`, plus the shared widgets they use
  (`PrimaryButton`, `AppTextField`, `AppBottomNavBar`, `SectionCard`).
- **What I kept, what I changed, and why:** I made some changes to the UI compared to my original mockup because the AI interpreted approximately 90% of my intended design. I also improved the overall design to make the application's interface more refined and visually appealing.
- **Commit:** Did not commit it.

### 2026-09-27 - Built Daily Log, Overview, and Profile (UI only)

- **Tool:** Claude (Sonnet)
- **What I asked for:** the remaining three screens' UI, explicitly UI-only
  at that point — backend/Gemini/database to follow later.
- **What it gave back:** the three screens plus two new shared components
  (`AddEntryRow`, `StatRow`), and wired real cross-screen navigation on
  Dashboard's bottom nav (previously a stub).
- **What I kept, what I changed, and why:** Same with the previous entry.
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/3c1dd067d03265b77aa5ad859df566caec695186

### 2026-09-28 - Built the backend: Supabase schema, auth, and the Gemini proxy

- **Tool:** Claude (Sonnet)
- **What I asked for:** Gemini API integration for food/drink validation and
  weekly health analysis, Supabase storage, real date-of-birth and
  username validation, a computed (non-AI) wellness score, and a real
  weekly sleep chart — replacing every placeholder except the avatar.
- **What it gave back:** `supabase/sql/schema.sql` (6 tables + RLS),
  `supabase/functions/gemini-proxy/` (an Edge Function so the Gemini key
  never ships in the Flutter build), and the service layer
  (`auth_service.dart`, `log_service.dart`, `gemini_service.dart`,
  `analysis_service.dart`, `wellness_score.dart`) wiring all four
  remaining screens to real data.
- **What I kept, what I changed, and why:** I retained the AI-generated implementation because, after reviewing the code, I found that it aligned with my intended database structure and Gemini API integration. The implementation also appeared to support how I envisioned the application's backend functionality and API interactions.
- **Commit:** Did not yet commit

### 2026-10-04 - Debugged deployment: white screen, email rate limit, missing tables

- **Tool:** Claude (Sonnet)
- **What I asked for:** help diagnosing a white screen on launch, then an
  "email rate limit exceeded" error, then "table not found" errors on
  Dashboard/Overview/Profile, then a `gemini-proxy` fetch failure.
- **What it gave back:** each diagnosed from the actual error text/stack
  trace I pasted — missing `--dart-define` flags, Supabase's default
  "Confirm email" setting being incompatible with this app's
  synthetic-email auth design, the SQL schema never having been run, and
  the Edge Function never having been deployed.
- **What I kept, what I changed, and why:** I disabled the default email confirmation requirement because my application does not require users to use a real email address for authentication. As a result, the application's login functionality is now working as intended.
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/1f78e432737e27dcf78c86fe75c52c4e888ba163

## 2. Where the AI got it wrong

Three cases. Be specific. If you write that the AI was never wrong, this section
scores zero.

### Case 1 - Dashboard header didn't cover the status bar / notch

- **What it gave me:** the original Dashboard screen wrapped its entire
  body — including the green header — in a `SafeArea`, which pushes
  content below the status bar/notch.
- **What was wrong with it:** that's wrong for a full-bleed colored header
  specifically: `SafeArea` protected the header's *content* correctly,
  but also pushed the header's *background color* down with it, leaving
  a visible gap of the default cream background behind the notch — I
  caught this from a screenshot, not from reading the code.
- **What I did instead:** reported the screenshot; the AI's fix removed
  the outer `SafeArea` and instead added `MediaQuery.of(context).padding.top`
  as extra padding on just the header `Container`, so the color extends
  to the true top of the screen while the content inside it still clears
  the notch.
- **Commit:** Did not commit.

### Case 2 - Outdated Supabase CLI install command

- **What it gave me:** `npm install -g supabase` as the way to install the
  Supabase CLI, as part of deploying the Gemini proxy Edge Function.
- **What was wrong with it:** running it failed — Supabase no longer
  supports installing their CLI as a global npm module at all. This was
  simply wrong information given with confidence, not a caveat I had to
  dig for.
- **What I did instead:** reported the exact error back; the AI searched
  and corrected itself, giving `npx supabase ...` (no global install
  needed) or Scoop as the Windows-recommended alternative.
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/1f78e432737e27dcf78c86fe75c52c4e888ba163

### Case 3 - ColorScheme.fromSeed didn't produce the exact color requested

- **What it gave me:** when I asked for the primary color to be changed to 
  #91AE6E, the AI set it via ColorScheme.fromSeed(seedColor: const Color(0xFF91AE6E)).
- **What was wrong with it:** the app bar and buttons rendered a visibly different,
  muddier green than #91AE6E — not a rendering bug, but how ColorScheme.fromSeed
  actually works: it runs the seed color through Material 3's tonal-palette
  algorithm and picks a derived shade, which isn't guaranteed to equal the literal
  hex you passed in. I caught this from a screenshot comparing the app bar against
  the actual hex value, not from reading the code.
- **What I did instead:** reported the mismatch with the screenshot;
  the AI explained the fromSeed derivation behavior and fixed it by
  pinning the color explicitly — .copyWith(primary: const Color(0xFF91AE6E)) — which overrides the
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/1f78e432737e27dcf78c86fe75c52c4e888ba163

## 3. Who wrote what

At least a fifth of this project is code you wrote yourself. Name it, and explain
it in your own words.

> Group projects: give each member their own heading below, and use your GitHub
> handle as the heading. You are graded on your own section.

### Written by me

- **File:** `lib/utils/date_validators.dart` `lib\utils\date_of_birth_formatter.dart`
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/1f78e432737e27dcf78c86fe75c52c4e888ba163
- **What it does and why it is built this way:** As mentioned in my previous weekly report, I planned to resolve this issue independently because I had already worked on similar tasks during the previous semester. I also wanted to maintain and improve my programming skills rather than rely entirely on AI assistance. Although this was only a small part of the overall project, I am still proud of accomplishing it on my own, as it allowed me to apply my existing knowledge and gain more confidence in my programming abilities.

### The AI-written part I understand best

- **File:** `lib/services/wellness_score.dart`
- **Commit:** https://github.com/Popcrastination/Kalinga/commit/1f78e432737e27dcf78c86fe75c52c4e888ba163
- **What it does and why we kept it:** It calculates a Wellness Score
  from 0–100 based on the user’s sleep, water intake, exercise, and meals.
  It compares each activity to its daily goal, averages the results,
  and updates the score instantly. I kept since it's very simple to
  understand and for the code.
