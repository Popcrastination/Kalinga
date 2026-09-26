import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/progress_chip.dart';
import '../widgets/section_card.dart';
import '../widgets/suggestion_tile.dart';
import 'daily_log_page.dart';
import 'overview_page.dart';
import 'profile_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

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

    // TODO(data): everything below is placeholder/sample data matching
    // the mockup. Replace with real values once these exist:
    //   - wellness score + trend  -> `health_analysis` table (Supabase)
    //   - today's progress chips  -> today's rows across food_logs,
    //     drink_logs, sleep_records, exercise_records
    //   - weekly sleep points     -> sleep_records for the last 7 days
    //   - quick insight text      -> Gemini-generated, stored on
    //     `health_analysis.suggestions_text`
    const wellnessScore = 75;
    const scoreDeltaLabel = '↑ 5% from yesterday';
    const weeklySleepHours = [6.5, 7.0, 5.5, 7.5, 6.0, 8.0, 7.5]; // Mon–Sun

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- Header: avatar + greeting --------------------------------
            Container(
              width: double.infinity,
              color: scheme.primary,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  // TODO(auth): the name comes from the logged-in user's
                  // profile once Supabase auth is wired in.
                  const AvatarPlaceholder(radius: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Hello there, John!',
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
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
                    // --- Wellness score card -------------------------------
                    SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Wellness Score', style: textTheme.labelSmall),
                          const SizedBox(height: 4),
                          Text(
                            '$wellnessScore / 100 %',
                            style: textTheme.headlineSmall?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scoreDeltaLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: scheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // --- Today's Progress ------------------------------------
                    Text("Today's Progress", style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    const Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        ProgressChip(
                          icon: Icons.bedtime,
                          label: 'Sleep — 7h 30m',
                          completed: true,
                        ),
                        ProgressChip(
                          icon: Icons.restaurant,
                          label: 'Meals 2/3',
                          completed: false,
                        ),
                        ProgressChip(
                          icon: Icons.water_drop,
                          label: 'Water 1.2/2.0L',
                          completed: false,
                        ),
                        ProgressChip(
                          icon: Icons.directions_run,
                          label: 'Activity — Not logged',
                          completed: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // --- Weekly sleep chart -----------------------------------
                    Text('Weekly Chart Sleep', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    SectionCard(
                      child: SizedBox(
                        height: 100,
                        width: double.infinity,
                        // Small hand-rolled line chart so this screen has no
                        // extra package dependency yet. Swap for fl_chart's
                        // LineChart later if richer interaction (tooltips,
                        // animation) is wanted.
                        child: CustomPaint(
                          painter: _SleepLineChartPainter(
                            values: weeklySleepHours,
                            lineColor: scheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // --- Quick insight -----------------------------------------
                    Text('Quick Insight', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    const SuggestionTile(
                      emoji: '💡',
                      description: "You've been sleeping more consistently this week.",
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}

/// Minimal line-chart painter for the Weekly Sleep chart. Draws [values]
/// (hours per day) as a connected line scaled to fill the canvas.
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
