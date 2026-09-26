import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_row.dart';
import 'daily_log_page.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'overview_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // TODO(data): all of this is placeholder/sample content matching the
  // mockup. Replace with the signed-in user's real row from `profiles`
  // (Supabase) once auth is wired in.
  static const _name = 'John David';
  static const _email = 'johndavid123@gmail.com';
  static const _age = '21';

  bool _isEditing = false;
  final _heightController = TextEditingController(text: '160');
  final _weightController = TextEditingController(text: '70');

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleEditTap() {
    if (_isEditing) {
      // TODO(data): persist _heightController.text / _weightController.text
      // to `profiles` (Supabase) here instead of just closing edit mode.
      // TODO(assets): wiring "add profile picture" also belongs here once
      // image upload (a stretch goal) is built.
    }
    setState(() => _isEditing = !_isEditing);
  }

  void _handleLogout() {
    // TODO(auth): call supabase.auth.signOut() here before navigating away.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _handleTabTap(int index) {
    if (index == 3) return; // already here
    final route = switch (index) {
      0 => MaterialPageRoute(builder: (_) => const DashboardPage()),
      1 => MaterialPageRoute(builder: (_) => const DailyLogPage()),
      2 => MaterialPageRoute(builder: (_) => const OverviewPage()),
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
          'Profile',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const AvatarPlaceholder(radius: 40),
              const SizedBox(height: AppSpacing.sm),
              Text(_name, style: textTheme.headlineSmall),
              Text(_email, style: textTheme.labelSmall),
              const SizedBox(height: AppSpacing.md),

              SectionCard(
                child: _isEditing
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            label: 'Height (cm)',
                            hint: 'in cm',
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppTextField(
                            label: 'Weight (kg)',
                            hint: 'in kg',
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          StatRow(icon: Icons.cake, label: 'Age', value: _age),
                          StatRow(
                            icon: Icons.height,
                            label: 'Height',
                            value: '${_heightController.text}cm',
                          ),
                          StatRow(
                            icon: Icons.monitor_weight,
                            label: 'Weight',
                            value: '${_weightController.text}kg',
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: AppSpacing.md),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Goals', style: textTheme.titleMedium),
              ),
              const SizedBox(height: AppSpacing.sm),
              // TODO(data): goals are placeholder values — once Profile can
              // be edited fully, these should come from the user's own
              // saved goals rather than being hardcoded here.
              const SectionCard(
                child: Column(
                  children: [
                    StatRow(icon: Icons.bedtime, label: 'Sleep', value: '8 hours'),
                    StatRow(icon: Icons.water_drop, label: 'Water', value: '2.0 L'),
                    StatRow(icon: Icons.directions_run, label: 'Activity', value: '30 min'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              PrimaryButton(
                label: _isEditing ? 'Save' : 'Edit',
                onPressed: _handleEditTap,
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _handleLogout,
                child: Text(
                  'Log out',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: _handleTabTap,
      ),
    );
  }
}
