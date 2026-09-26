import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_row.dart';
import '../widgets/suggestion_tile.dart';
import 'daily_log_page.dart';
import 'dashboard_page.dart';
import 'profile_page.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

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

    // TODO(data): everything below is placeholder/sample content matching
    // the mockup. Replace with real values once these exist:
    //   - Daily Summary text + breakdown -> `health_analysis`
    //     (daily_summary_text), computed/generated from today's logs
    //   - Weekly trend percentages       -> computed from the last 7 days
    //     across sleep_records / drink_logs / exercise_records
    //   - Suggestions                    -> Gemini-generated, stored on
    //     `health_analysis.suggestions_text`

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        title: Text(
          'Overview',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                      'You had a balanced day overall. Your food intake '
                      'included a good amount of protein, but your water '
                      'intake was slightly below your target. You also got '
                      '7h 40m of sleep.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    const StatRow(icon: Icons.bedtime, label: 'Sleep', value: '7h 40m'),
                    const StatRow(icon: Icons.water_drop, label: 'Water', value: '1.8 L'),
                    const StatRow(icon: Icons.directions_run, label: 'Activity', value: '42 min'),
                    const StatRow(icon: Icons.restaurant, label: 'Meals', value: '3'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Weekly Summary', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              SectionCard(
                child: Column(
                  children: const [
                    StatRow(icon: Icons.bedtime, label: 'Sleep', value: '↑ 12%'),
                    StatRow(icon: Icons.directions_run, label: 'Activity', value: '→ Stable'),
                    StatRow(icon: Icons.water_drop, label: 'Water', value: '↓ 8%'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Suggestion', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              const SuggestionTile(
                emoji: '💧',
                title: 'Drink more water',
                description: 'Try adding one extra glass of water during the afternoon.',
              ),
              const SizedBox(height: AppSpacing.sm),
              const SuggestionTile(
                emoji: '😴',
                title: 'Keep your sleep schedule consistent',
                description: 'Your sleep duration varies by almost 2 hours across the week.',
              ),
              const SizedBox(height: AppSpacing.sm),
              const SuggestionTile(
                emoji: '🥗',
                title: 'Add more vegetables',
                description: 'Your recent meals show fewer vegetables than other food groups.',
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 2,
        onTap: (index) => _handleTabTap(context, index),
      ),
    );
  }
}
