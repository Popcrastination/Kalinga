/// One suggestion in a [HealthAnalysis] — matches [SuggestionTile]'s shape
/// directly so the UI can render Gemini's output with no extra mapping.
class Suggestion {
  const Suggestion({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;

  factory Suggestion.fromMap(Map<String, dynamic> map) => Suggestion(
        emoji: map['emoji'] as String? ?? '💡',
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'emoji': emoji,
        'title': title,
        'description': description,
      };
}

/// Mirrors `health_analysis`. One row per user per day — generated once by
/// Gemini and then reused for the rest of that day (see
/// lib/services/analysis_service.dart), rather than re-calling the API
/// every time Dashboard or Overview is opened.
class HealthAnalysis {
  const HealthAnalysis({
    required this.wellnessScore,
    required this.dailySummaryText,
    required this.weeklyTrends,
    required this.suggestions,
    required this.analysisDate,
  });

  /// 0–100. Computed locally (see lib/services/wellness_score.dart), NOT
  /// by Gemini — this field is filled in before the row is saved, not by
  /// the model's JSON response.
  final int wellnessScore;

  final String dailySummaryText;

  /// e.g. {"sleep": "↑ 12%", "activity": "→ Stable", "water": "↓ 8%"}
  final Map<String, String> weeklyTrends;

  final List<Suggestion> suggestions;
  final DateTime analysisDate;

  factory HealthAnalysis.fromMap(Map<String, dynamic> map) {
    final trendsRaw = map['weekly_trend_json'] as Map<String, dynamic>? ?? {};
    final suggestionsRaw = map['suggestions_text'] as List<dynamic>? ?? [];
    return HealthAnalysis(
      wellnessScore: map['wellness_score'] as int,
      dailySummaryText: map['daily_summary_text'] as String? ?? '',
      weeklyTrends: trendsRaw.map((k, v) => MapEntry(k, v as String)),
      suggestions: suggestionsRaw
          .map((s) => Suggestion.fromMap(s as Map<String, dynamic>))
          .toList(),
      analysisDate: DateTime.parse(map['analysis_date'] as String),
    );
  }

  Map<String, dynamic> toInsertMap(String userId) => {
        'user_id': userId,
        'wellness_score': wellnessScore,
        'daily_summary_text': dailySummaryText,
        'weekly_trend_json': weeklyTrends,
        'suggestions_text': suggestions.map((s) => s.toMap()).toList(),
        'analysis_date': analysisDate.toIso8601String().split('T').first,
      };
}
