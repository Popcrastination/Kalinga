import '../models/health_analysis.dart';
import 'gemini_service.dart';
import 'log_service.dart';
import 'supabase_config.dart';
import 'wellness_score.dart';

/// The single choke point that limits Gemini calls to once per user per
/// day. Both Dashboard's Quick Insight and Overview's Daily/Weekly
/// Summary + Suggestions call this same method — whichever screen opens
/// first on a given day pays the one Gemini call; every other screen (and
/// every re-open of either screen that day) reads the cached row instead.
class AnalysisService {
  static String _today() => DateTime.now().toIso8601String().split('T').first;

  static Future<HealthAnalysis> getOrGenerateToday({
    required String userId,
    required double heightCm,
    required double weightKg,
  }) async {
    final today = _today();

    final cached = await supabase
        .from('health_analysis')
        .select()
        .eq('user_id', userId)
        .eq('analysis_date', today)
        .maybeSingle();

    if (cached != null) {
      return HealthAnalysis.fromMap(cached);
    }

    // No cached row for today yet. Everything a generated analysis needs
    // comes from the last 7 days of logs.
    final week = await LogService.fetchWeek(userId);
    final todaySummary = await LogService.fetchToday(userId);
    final score = WellnessScore.compute(todaySummary);

    final hasAnyData = week.food.isNotEmpty ||
        week.drinks.isNotEmpty ||
        week.sleep.isNotEmpty ||
        week.exercise.isNotEmpty;

    final HealthAnalysis analysis;
    if (!hasAnyData) {
      // A brand-new account, or a week with nothing logged yet. Spending a
      // Gemini call analyzing zero data rows is pure waste — and risky,
      // since the model has nothing concrete to summarize and could
      // return something that doesn't match the requested JSON shape.
      // Short-circuit locally instead.
      analysis = HealthAnalysis(
        wellnessScore: score, // 0, honestly, until something is logged
        dailySummaryText: "You haven't logged anything yet today — head to "
            'Daily Log to get started.',
        weeklyTrends: const {},
        suggestions: const [
          Suggestion(
            emoji: '👋',
            title: 'Log your first entry',
            description:
                'Add a meal, a drink, your sleep, or some exercise on Daily '
                'Log — insights and trends show up here once there\'s '
                'something to work from.',
          ),
        ],
        analysisDate: DateTime.now(),
      );
    } else {
      // This is the one Gemini call for the whole day — see the class
      // comment above for why only one call happens per user per day.
      final result = await GeminiService.analyzeWeek(
        heightCm: heightCm,
        weightKg: weightKg,
        food: week.food,
        drinks: week.drinks,
        sleep: week.sleep,
        exercise: week.exercise,
      );

      analysis = HealthAnalysis(
        wellnessScore: score,
        dailySummaryText: result.dailySummaryText,
        weeklyTrends: result.weeklyTrends,
        suggestions: result.suggestions
            .map((s) => Suggestion(
                  emoji: s.emoji,
                  title: s.title,
                  description: s.description,
                ))
            .toList(),
        analysisDate: DateTime.now(),
      );
    }

    await supabase.from('health_analysis').insert(analysis.toInsertMap(userId));
    return analysis;
  }
}
