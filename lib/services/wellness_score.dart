import '../constants/wellness_goals.dart';
import '../models/daily_logs.dart';

/// Computes the Dashboard's "Wellness Score: X / 100 %" from today's
/// logged data against [WellnessGoals]. Deliberately a plain formula, not
/// a Gemini call — the wellness score needs to update instantly as soon as
/// something is logged, and a formula the user's own numbers plug into is
/// more honest here than an AI guess would be.
///
/// Four equally-weighted components, each capped at 100 so overshooting
/// one goal (e.g. sleeping 10 hours) can't inflate the total average past
/// what full marks on every component would give.
class WellnessScore {
  WellnessScore._();

  static int compute(DailyLogSummary today) {
    final sleepScore = _capped(
      (today.sleepHours ?? 0) / WellnessGoals.sleepHours,
    );
    final waterScore = _capped(today.totalWaterMl / WellnessGoals.waterMl);
    final exerciseScore = _capped(
      (today.exerciseMinutes ?? 0) / WellnessGoals.exerciseMinutes,
    );
    final mealScore = _capped(today.mealsLoggedCount / WellnessGoals.meals);

    final average =
        (sleepScore + waterScore + exerciseScore + mealScore) / 4;
    return (average * 100).round().clamp(0, 100);
  }

  static double _capped(double ratio) => ratio > 1 ? 1 : (ratio < 0 ? 0 : ratio);
}
