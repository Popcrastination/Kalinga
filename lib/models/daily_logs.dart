/// Mirrors `food_logs`. [mealType] is one of 'breakfast', 'lunch', 'dinner'.
class FoodLog {
  const FoodLog({
    required this.mealType,
    required this.description,
    required this.loggedAt,
  });

  final String mealType;
  final String description;
  final DateTime loggedAt;

  factory FoodLog.fromMap(Map<String, dynamic> map) => FoodLog(
        mealType: map['meal_type'] as String,
        description: map['description'] as String,
        loggedAt: DateTime.parse(map['logged_at'] as String),
      );
}

/// Mirrors `drink_logs`. [amountMl] is nullable because the current UI's
/// entry sheet doesn't always ask for a quantity — see AddEntryRow usage
/// in daily_log_page.dart.
class DrinkLog {
  const DrinkLog({
    required this.description,
    required this.amountMl,
    required this.loggedAt,
  });

  final String description;
  final double? amountMl;
  final DateTime loggedAt;

  factory DrinkLog.fromMap(Map<String, dynamic> map) => DrinkLog(
        description: map['description'] as String,
        amountMl: (map['amount_ml'] as num?)?.toDouble(),
        loggedAt: DateTime.parse(map['logged_at'] as String),
      );
}

/// Mirrors `sleep_records`. One row per calendar day.
class SleepRecord {
  const SleepRecord({required this.durationHours, required this.date});

  final double durationHours;
  final DateTime date;

  factory SleepRecord.fromMap(Map<String, dynamic> map) => SleepRecord(
        durationHours: (map['duration_hours'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
      );
}

/// Mirrors `exercise_records`. One row per calendar day.
class ExerciseRecord {
  const ExerciseRecord({required this.durationMinutes, required this.date});

  final double durationMinutes;
  final DateTime date;

  factory ExerciseRecord.fromMap(Map<String, dynamic> map) => ExerciseRecord(
        durationMinutes: (map['duration_minutes'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
      );
}

/// Everything logged "today" for one user — the shape the wellness-score
/// calculation and the Dashboard's Today's Progress chips both read from.
class DailyLogSummary {
  const DailyLogSummary({
    required this.foodLogs,
    required this.drinkLogs,
    required this.sleepHours,
    required this.exerciseMinutes,
  });

  final List<FoodLog> foodLogs;
  final List<DrinkLog> drinkLogs;
  final double? sleepHours;
  final double? exerciseMinutes;

  double get totalWaterMl =>
      drinkLogs.fold(0.0, (sum, d) => sum + (d.amountMl ?? 0));

  bool get hasBreakfast => foodLogs.any((f) => f.mealType == 'breakfast');
  bool get hasLunch => foodLogs.any((f) => f.mealType == 'lunch');
  bool get hasDinner => foodLogs.any((f) => f.mealType == 'dinner');
  int get mealsLoggedCount =>
      [hasBreakfast, hasLunch, hasDinner].where((v) => v).length;
}
