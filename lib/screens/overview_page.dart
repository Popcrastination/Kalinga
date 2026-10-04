import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../models/daily_logs.dart';
import '../models/health_analysis.dart';
import '../services/analysis_service.dart';
import '../services/auth_service.dart';
import '../services/log_service.dart';
import '../services/profile_service.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/error_view.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_row.dart';
import '../widgets/suggestion_tile.dart';
import 'daily_log_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class _OverviewData {
  const _OverviewData({required this.today, required this.analysis});
  final DailyLogSummary today;
  final HealthAnalysis analysis;
}

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  late Future<_OverviewData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
  }

  Future<_OverviewData> _load() async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw StateError('No signed-in user.');

    final profile = await ProfileService.fetch(userId);
    final today = await LogService.fetchToday(userId);
    // Same cached row Dashboard reads/writes — opening Overview right
    // after Dashboard on the same day costs zero extra Gemini calls.
    final analysis = await AnalysisService.getOrGenerateToday(
      userId: userId,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
    );

    return _OverviewData(today: today, analysis: analysis);
  }

  void _handleTabTap(BuildContext context, int index) {
    if (index == 2) return; // already here
    final route = switch (index) {
      0 => MaterialPageRoute(builder: (_) => const DashboardPage()),
      1 => MaterialPageRoute(builder: (_) => const DailyLogPage()),
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
      appBar: AppBar(
        backgroundColor: scheme.primary,
        title: Text(
          'Overview',
          style: textTheme.headlineSmall?.copyWith(color: scheme.onPrimary),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<_OverviewData>(
          future: _dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorView(
                message: 'Could not load your overview: ${snapshot.error}',
                onLoggedOut: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                ),
              );
            }

            final data = snapshot.data!;
            final today = data.today;
            final analysis = data.analysis;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Daily Summary', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.dailySummaryText.isNotEmpty
                              ? analysis.dailySummaryText
                              : 'Log a few things today to get a summary here.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Divider(height: 1),
                        const SizedBox(height: AppSpacing.sm),
                        StatRow(
                          icon: Icons.bedtime,
                          label: 'Sleep',
                          value: today.sleepHours == null ? '—' : '${today.sleepHours}h',
                        ),
                        StatRow(
                          icon: Icons.water_drop,
                          label: 'Water',
                          value: '${(today.totalWaterMl / 1000).toStringAsFixed(1)} L',
                        ),
                        StatRow(
                          icon: Icons.directions_run,
                          label: 'Activity',
                          value: today.exerciseMinutes == null
                              ? '—'
                              : '${today.exerciseMinutes}min',
                        ),
                        StatRow(
                          icon: Icons.restaurant,
                          label: 'Meals',
                          value: '${today.mealsLoggedCount}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Weekly Summary', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  SectionCard(
                    child: analysis.weeklyTrends.isEmpty
                        ? Text('Not enough data yet.', style: textTheme.labelSmall)
                        : Column(
                            children: analysis.weeklyTrends.entries.map((entry) {
                              final icon = switch (entry.key) {
                                'sleep' => Icons.bedtime,
                                'water' => Icons.water_drop,
                                'activity' => Icons.directions_run,
                                _ => Icons.insights,
                              };
                              return StatRow(
                                icon: icon,
                                label: entry.key[0].toUpperCase() + entry.key.substring(1),
                                value: entry.value,
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Suggestion', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  if (analysis.suggestions.isEmpty)
                    Text(
                      'Log a few days of data to get personalized suggestions.',
                      style: textTheme.labelSmall,
                    )
                  else
                    for (final s in analysis.suggestions) ...[
                      SuggestionTile(
                        emoji: s.emoji,
                        title: s.title,
                        description: s.description,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}
