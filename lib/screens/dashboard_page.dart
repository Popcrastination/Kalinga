import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/wellness_goals.dart';
import '../models/daily_logs.dart';
import '../models/health_analysis.dart';
import '../models/user_profile.dart';
import '../services/analysis_service.dart';
import '../services/auth_service.dart';
import '../services/log_service.dart';
import '../services/profile_service.dart';
import '../services/supabase_config.dart';
import '../services/wellness_score.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/error_view.dart';
import '../widgets/progress_chip.dart';
import '../widgets/section_card.dart';
import '../widgets/suggestion_tile.dart';
import 'daily_log_page.dart';
import 'login_page.dart';
import 'overview_page.dart';
import 'profile_page.dart';

class _DashboardData {
  const _DashboardData({
    required this.profile,
    required this.today,
    required this.weekSleep,
    required this.analysis,
    required this.yesterdayScore,
  });

  final UserProfile profile;
  final DailyLogSummary today;
  final List<double> weekSleep; // hours, oldest first, gaps skipped
  final HealthAnalysis analysis;
  final int? yesterdayScore;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<_DashboardData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  Future<_DashboardData> _load() async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw StateError('No signed-in user.');

    final profile = await ProfileService.fetch(userId);
    final today = await LogService.fetchToday(userId);
    final weekSleepRecords = await LogService.fetchWeekSleep(userId);

    final analysis = await AnalysisService.getOrGenerateToday(
      userId: userId,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
    );

    // Read-only look at yesterday's cached row, if one exists — never
    // generates one, since that would mean a second Gemini call just to
    // show a delta. No row simply means no delta shown.
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;
    final yesterdayRow = await supabase
        .from('health_analysis')
        .select('wellness_score')
        .eq('user_id', userId)
        .eq('analysis_date', yesterday)
        .maybeSingle();

    return _DashboardData(
      profile: profile,
      today: today,
      weekSleep: weekSleepRecords.map((r) => r.durationHours).toList(),
      analysis: analysis,
      yesterdayScore: yesterdayRow?['wellness_score'] as int?,
    );
  }

  // Dashboard is index 0. pushReplacement (not push) so switching tabs
  // doesn't pile up a back stack — each tab replaces the current screen.
  // NOTE: this same four-case switch is duplicated in Daily Log, Overview,
  // and Profile. Worth factoring into one shared "tab shell" widget later;
  // left duplicated for now since each screen is still simple on its own.
  void _handleTabTap(BuildContext context, int index) {
    if (index == 0) return; // already here
    final route = switch (index) {
      1 => MaterialPageRoute(builder: (_) => const DailyLogPage()),
      2 => MaterialPageRoute(builder: (_) => const OverviewPage()),
      3 => MaterialPageRoute(builder: (_) => const ProfilePage()),
      _ => null,
    };
    if (route != null) {
      Navigator.of(context).pushReplacement(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FutureBuilder<_DashboardData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: 'Could not load your dashboard: ${snapshot.error}',
              onLoggedOut: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              ),
            );
          }

          final data = snapshot.data!;
          final wellnessScore = WellnessScore.compute(data.today);
          final scoreDelta = data.yesterdayScore == null
              ? null
              : wellnessScore - data.yesterdayScore!;

          return Column(
            children: [
              // --- Header: avatar + greeting ------------------------------
              // No SafeArea wrapping this: it needs to paint all the way to
              // the very top (behind the status bar / notch), which is
              // exactly what SafeArea prevents. Instead, the notch height
              // itself is added as extra top padding so the *content*
              // still clears it while the green *background* doesn't stop
              // short of it.
              Container(
                width: double.infinity,
                color: scheme.primary,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  MediaQuery.of(context).padding.top + AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    const AvatarPlaceholder(radius: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Hello there, ${data.profile.firstName}!',
                      style: textTheme.titleMedium?.copyWith(color: scheme.onPrimary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- Wellness score card ---------------------------
                      SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Wellness Score', style: textTheme.labelSmall),
                            const SizedBox(height: 4),
                            Text(
                              '$wellnessScore / 100 %',
                              style: textTheme.headlineSmall?.copyWith(color: scheme.primary),
                            ),
                            if (scoreDelta != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                scoreDelta >= 0
                                    ? '↑ $scoreDelta% from yesterday'
                                    : '↓ ${scoreDelta.abs()}% from yesterday',
                                style: textTheme.labelSmall?.copyWith(color: scheme.secondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // --- Today's Progress --------------------------------
                      Text("Today's Progress", style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          ProgressChip(
                            icon: Icons.bedtime,
                            label: data.today.sleepHours == null
                                ? 'Sleep — Not logged'
                                : 'Sleep — ${data.today.sleepHours}h',
                            completed: (data.today.sleepHours ?? 0) >= WellnessGoals.sleepHours,
                          ),
                          ProgressChip(
                            icon: Icons.restaurant,
                            label: 'Meals ${data.today.mealsLoggedCount}/${WellnessGoals.meals}',
                            completed: data.today.mealsLoggedCount >= WellnessGoals.meals,
                          ),
                          ProgressChip(
                            icon: Icons.water_drop,
                            label:
                                'Water ${(data.today.totalWaterMl / 1000).toStringAsFixed(1)}/${(WellnessGoals.waterMl / 1000).toStringAsFixed(1)}L',
                            completed: data.today.totalWaterMl >= WellnessGoals.waterMl,
                          ),
                          ProgressChip(
                            icon: Icons.directions_run,
                            label: data.today.exerciseMinutes == null
                                ? 'Activity — Not logged'
                                : 'Activity — ${data.today.exerciseMinutes}min',
                            completed:
                                (data.today.exerciseMinutes ?? 0) >= WellnessGoals.exerciseMinutes,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // --- Weekly sleep chart -------------------------------
                      Text('Weekly Chart Sleep', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      SectionCard(
                        child: SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: data.weekSleep.isEmpty
                              ? Center(
                                  child: Text(
                                    'No sleep logged yet this week',
                                    style: textTheme.labelSmall,
                                  ),
                                )
                              // Small hand-rolled line chart so this screen
                              // has no extra package dependency. Swap for
                              // fl_chart's LineChart later if richer
                              // interaction (tooltips, animation) is wanted.
                              : CustomPaint(
                                  painter: _SleepLineChartPainter(
                                    values: data.weekSleep,
                                    lineColor: scheme.secondary,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // --- Quick insight -------------------------------------
                      Text('Quick Insight', style: textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.sm),
                      SuggestionTile(
                        emoji: '💡',
                        description: data.analysis.suggestions.isNotEmpty
                            ? data.analysis.suggestions.first.description
                            : 'Log a few days of data to start seeing insights here.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}

/// Minimal line-chart painter for the Weekly Sleep chart. Draws [values]
/// (hours per day, oldest first) as a connected line scaled to fill the
/// canvas. Plots by index, not by calendar date — a day with no record is
/// simply absent from [values] rather than shown as 0.
class _SleepLineChartPainter extends CustomPainter {
  _SleepLineChartPainter({required this.values, required this.lineColor});

  final List<double> values;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue) <= 0 ? 1 : (maxValue - minValue);

    final stepX = values.length > 1 ? size.width / (values.length - 1) : 0.0;
    final points = <Offset>[
      for (int i = 0; i < values.length; i++)
        Offset(
          i * stepX,
          size.height - ((values[i] - minValue) / range) * size.height,
        ),
    ];

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = lineColor;
    for (final point in points) {
      canvas.drawCircle(point, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SleepLineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
