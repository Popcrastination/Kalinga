/// Default daily targets. Not per-user yet — there's no `goals` table in
/// the schema (the proposal never planned one), so these are fixed
/// constants used both to compute the wellness score below and to display
/// Profile's Goals card, rather than inventing per-user goal storage this
/// pass didn't ask for.
class WellnessGoals {
  WellnessGoals._();

  static const double sleepHours = 8;
  static const double waterMl = 2000;
  static const double exerciseMinutes = 30;
  static const int meals = 3;
}
