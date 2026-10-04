import '../models/daily_logs.dart';
import 'supabase_config.dart';

class WeeklyAnalysisResult {
  const WeeklyAnalysisResult({
    required this.dailySummaryText,
    required this.weeklyTrends,
    required this.suggestions,
  });

  final String dailySummaryText;
  final Map<String, String> weeklyTrends;
  final List<({String emoji, String title, String description})> suggestions;

  factory WeeklyAnalysisResult.fromJson(Map<String, dynamic> json) {
    final trends = (json['weeklyTrends'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, v.toString()));
    final suggestionsRaw = json['suggestions'] as List<dynamic>? ?? [];
    return WeeklyAnalysisResult(
      dailySummaryText: json['dailySummaryText'] as String? ?? '',
      weeklyTrends: trends,
      suggestions: suggestionsRaw.map((s) {
        final m = s as Map<String, dynamic>;
        return (
          emoji: m['emoji'] as String? ?? '💡',
          title: m['title'] as String? ?? '',
          description: m['description'] as String? ?? '',
        );
      }).toList(),
    );
  }
}

/// Every call here goes through the `gemini-proxy` Supabase Edge Function
/// (see supabase/functions/gemini-proxy/index.ts) — never directly to
/// Google. This file never touches a Gemini API key; only the Edge
/// Function does.
class GeminiService {
  /// Validates one meal/drink entry. Returns true if Gemini judged it a
  /// real food/drink item.
  ///
  /// A cheap, non-AI pre-filter runs first: empty or trivially-short input
  /// is rejected for free, without spending a single token on a call that
  /// was never going to say YES anyway.
  static Future<bool> validateFoodOrDrink(String input) async {
    final trimmed = input.trim();
    if (trimmed.length < 2) return false;

    final res = await supabase.functions.invoke(
      'gemini-proxy',
      body: {'action': 'validate', 'payload': {'input': trimmed}},
    );

    if (res.status != 200) {
      throw GeminiServiceException(
        'Validation request failed (${res.status}). Is the gemini-proxy '
        'function deployed and GEMINI_API_KEY set as its secret?',
      );
    }
    return (res.data as Map)['isValid'] as bool;
  }

  /// One call per user per day — see AnalysisService, which is what
  /// actually enforces that cap. This method itself doesn't cache
  /// anything; it always calls Gemini when invoked.
  static Future<WeeklyAnalysisResult> analyzeWeek({
    required double heightCm,
    required double weightKg,
    required List<FoodLog> food,
    required List<DrinkLog> drinks,
    required List<SleepRecord> sleep,
    required List<ExerciseRecord> exercise,
  }) async {
    final res = await supabase.functions.invoke(
      'gemini-proxy',
      body: {
        'action': 'analyze',
        'payload': {
          'heightCm': heightCm,
          'weightKg': weightKg,
          'food': food
              .map((f) => {
                    'mealType': f.mealType,
                    'description': f.description,
                    'loggedAt': f.loggedAt.toIso8601String(),
                  })
              .toList(),
          'drinks': drinks
              .map((d) => {
                    'description': d.description,
                    'amountMl': d.amountMl,
                    'loggedAt': d.loggedAt.toIso8601String(),
                  })
              .toList(),
          'sleep': sleep
              .map((s) => {
                    'durationHours': s.durationHours,
                    'date': s.date.toIso8601String().split('T').first,
                  })
              .toList(),
          'exercise': exercise
              .map((e) => {
                    'durationMinutes': e.durationMinutes,
                    'date': e.date.toIso8601String().split('T').first,
                  })
              .toList(),
        },
      },
    );

    if (res.status != 200) {
      throw GeminiServiceException(
        'Weekly analysis request failed (${res.status}).',
      );
    }
    return WeeklyAnalysisResult.fromJson(res.data as Map<String, dynamic>);
  }
}

class GeminiServiceException implements Exception {
  GeminiServiceException(this.message);
  final String message;
  @override
  String toString() => message;
}
