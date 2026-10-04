import '../models/daily_logs.dart';
import 'supabase_config.dart';

/// Format Supabase's `date` columns want: YYYY-MM-DD, no time component.
String _dateOnly(DateTime d) => d.toIso8601String().split('T').first;

class LogService {
  // --- Inserts --------------------------------------------------------

  static Future<void> insertFoodLog({
    required String userId,
    required String mealType, // 'breakfast' | 'lunch' | 'dinner'
    required String description,
  }) {
    return supabase.from('food_logs').insert({
      'user_id': userId,
      'meal_type': mealType,
      'description': description,
      'gemini_validated': true, // only reaches here after Gemini approved it
      'logged_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> insertDrinkLog({
    required String userId,
    required String description,
    double? amountMl,
  }) {
    return supabase.from('drink_logs').insert({
      'user_id': userId,
      'description': description,
      'amount_ml': amountMl,
      'gemini_validated': true,
      'logged_at': DateTime.now().toIso8601String(),
    });
  }

  /// Upserts, since there's one sleep record per day — logging Sleep twice
  /// in one day should replace, not duplicate.
  static Future<void> upsertSleepRecord({
    required String userId,
    required double hours,
  }) {
    return supabase.from('sleep_records').upsert({
      'user_id': userId,
      'duration_hours': hours,
      'date': _dateOnly(DateTime.now()),
    }, onConflict: 'user_id,date');
  }

  static Future<void> upsertExerciseRecord({
    required String userId,
    required double minutes,
  }) {
    return supabase.from('exercise_records').upsert({
      'user_id': userId,
      'duration_minutes': minutes,
      'date': _dateOnly(DateTime.now()),
    }, onConflict: 'user_id,date');
  }

  // --- Reads ------------------------------------------------------------

  static Future<DailyLogSummary> fetchToday(String userId) async {
    final today = _dateOnly(DateTime.now());
    final startOfDay = '${today}T00:00:00';
    final endOfDay = '${today}T23:59:59';

    final foodRows = await supabase
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', startOfDay)
        .lte('logged_at', endOfDay);

    final drinkRows = await supabase
        .from('drink_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', startOfDay)
        .lte('logged_at', endOfDay);

    final sleepRows = await supabase
        .from('sleep_records')
        .select()
        .eq('user_id', userId)
        .eq('date', today);

    final exerciseRows = await supabase
        .from('exercise_records')
        .select()
        .eq('user_id', userId)
        .eq('date', today);

    return DailyLogSummary(
      foodLogs: foodRows.map((r) => FoodLog.fromMap(r)).toList(),
      drinkLogs: drinkRows.map((r) => DrinkLog.fromMap(r)).toList(),
      sleepHours: sleepRows.isEmpty
          ? null
          : (sleepRows.first['duration_hours'] as num).toDouble(),
      exerciseMinutes: exerciseRows.isEmpty
          ? null
          : (exerciseRows.first['duration_minutes'] as num).toDouble(),
    );
  }

  /// Last 7 calendar days of sleep, oldest first — what the Dashboard's
  /// weekly chart draws. Days with no record are left out rather than
  /// padded with a fake 0, so the chart doesn't imply "0 hours slept" for
  /// a day that just has no data yet.
  static Future<List<SleepRecord>> fetchWeekSleep(String userId) async {
    final sevenDaysAgo = _dateOnly(
      DateTime.now().subtract(const Duration(days: 6)),
    );
    final rows = await supabase
        .from('sleep_records')
        .select()
        .eq('user_id', userId)
        .gte('date', sevenDaysAgo)
        .order('date');
    return rows.map((r) => SleepRecord.fromMap(r)).toList();
  }

  /// Everything from the last 7 days, across all four tables — the input
  /// to Gemini's weekly analysis (see AnalysisService).
  static Future<
      ({
        List<FoodLog> food,
        List<DrinkLog> drinks,
        List<SleepRecord> sleep,
        List<ExerciseRecord> exercise,
      })> fetchWeek(String userId) async {
    final sevenDaysAgo = _dateOnly(
      DateTime.now().subtract(const Duration(days: 6)),
    );
    final startOfWeek = '${sevenDaysAgo}T00:00:00';

    final foodRows = await supabase
        .from('food_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', startOfWeek);
    final drinkRows = await supabase
        .from('drink_logs')
        .select()
        .eq('user_id', userId)
        .gte('logged_at', startOfWeek);
    final sleepRows = await supabase
        .from('sleep_records')
        .select()
        .eq('user_id', userId)
        .gte('date', sevenDaysAgo);
    final exerciseRows = await supabase
        .from('exercise_records')
        .select()
        .eq('user_id', userId)
        .gte('date', sevenDaysAgo);

    return (
      food: foodRows.map((r) => FoodLog.fromMap(r)).toList(),
      drinks: drinkRows.map((r) => DrinkLog.fromMap(r)).toList(),
      sleep: sleepRows.map((r) => SleepRecord.fromMap(r)).toList(),
      exercise: exerciseRows.map((r) => ExerciseRecord.fromMap(r)).toList(),
    );
  }
}
