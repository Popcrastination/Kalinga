import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../constants/wellness_goals.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/avatar_placeholder.dart';
import '../widgets/error_view.dart';
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
  late Future<UserProfile> _profileFuture;

  bool _isEditing = false;
  bool _isSaving = false;
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profileFuture = _load();
  }

  Future<UserProfile> _load() async {
    final userId = AuthService.currentUserId;
    if (userId == null) throw StateError('No signed-in user.');
    final profile = await ProfileService.fetch(userId);
    _heightController.text = profile.heightCm.toString();
    _weightController.text = profile.weightKg.toString();
    return profile;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _handleEditTap() async {
    if (!_isEditing) {
      setState(() => _isEditing = true);
      return;
    }

    // Currently editing — this tap means Save.
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height == null || weight == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Height and weight must be numbers')));
      return;
    }

    setState(() => _isSaving = true);
    final userId = AuthService.currentUserId!;
    await ProfileService.updateHeightAndWeight(
      userId: userId,
      heightCm: height,
      weightKg: weight,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _isEditing = false;
      _profileFuture = _load(); // refetch so the read-only view shows the saved values
    });
    // TODO(assets): wiring "add profile picture" also belongs here once
    // image upload (a stretch goal) is built — the avatar stays a
    // placeholder for now, deliberately, per the current scope.
  }

  Future<void> _handleLogout() async {
    await AuthService.signOut();
    if (!mounted) return;
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
          style: textTheme.headlineSmall?.copyWith(color: scheme.onPrimary),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<UserProfile>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorView(
                message: 'Could not load your profile: ${snapshot.error}',
                onLoggedOut: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                ),
              );
            }

            final profile = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Real profile picture upload isn't built yet (stretch
                  // goal) — this is the one placeholder left, deliberately.
                  const AvatarPlaceholder(radius: 40),
                  const SizedBox(height: AppSpacing.sm),
                  Text(profile.fullName, style: textTheme.headlineSmall),
                  Text('@${profile.username}', style: textTheme.labelSmall),
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
                              StatRow(icon: Icons.cake, label: 'Age', value: '${profile.age}'),
                              StatRow(
                                icon: Icons.height,
                                label: 'Height',
                                value: '${profile.heightCm}cm',
                              ),
                              StatRow(
                                icon: Icons.monitor_weight,
                                label: 'Weight',
                                value: '${profile.weightKg}kg',
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
                  // These are the same WellnessGoals constants the wellness
                  // score and Today's Progress chips are computed against
                  // — not separate fake numbers, since there's no
                  // per-user goals table in the schema yet.
                  SectionCard(
                    child: Column(
                      children: [
                        StatRow(
                          icon: Icons.bedtime,
                          label: 'Sleep',
                          value: '${WellnessGoals.sleepHours.toInt()} hours',
                        ),
                        StatRow(
                          icon: Icons.water_drop,
                          label: 'Water',
                          value: '${(WellnessGoals.waterMl / 1000).toStringAsFixed(1)} L',
                        ),
                        StatRow(
                          icon: Icons.directions_run,
                          label: 'Activity',
                          value: '${WellnessGoals.exerciseMinutes.toInt()} min',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  PrimaryButton(
                    label: _isEditing ? 'Save' : 'Edit',
                    isLoading: _isSaving,
                    onPressed: _handleEditTap,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(color: scheme.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _handleLogout,
                    child: Text('Log out', style: TextStyle(color: scheme.error)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 3,
        onTap: _handleTabTap,
      ),
    );
  }
}
