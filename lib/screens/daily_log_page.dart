import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../models/daily_logs.dart';
import '../services/auth_service.dart';
import '../services/gemini_service.dart';
import '../services/log_service.dart';
import '../widgets/add_entry_row.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/error_view.dart';
import '../widgets/primary_button.dart';
import 'dashboard_page.dart';
import 'login_page.dart';
import 'overview_page.dart';
import 'profile_page.dart';

class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  late Future<DailyLogSummary> _todayFuture;

  final _sleepController = TextEditingController();
  final _exerciseController = TextEditingController();
  final _sleepFocusNode = FocusNode();
  final _exerciseFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _todayFuture = _loadToday();
    _sleepFocusNode.addListener(() {
      if (!_sleepFocusNode.hasFocus) _saveSleep();
    });
    _exerciseFocusNode.addListener(() {
      if (!_exerciseFocusNode.hasFocus) _saveExercise();
    });
  }

  Future<DailyLogSummary> _loadToday() async {
    final userId = AuthService.currentUserId;
    if (userId == null) {
      // Shouldn't happen — this screen is only reachable while signed in —
      // but fail loudly instead of crashing on a null user id.
      throw StateError('No signed-in user.');
    }
    final summary = await LogService.fetchToday(userId);
    _sleepController.text = summary.sleepHours?.toString() ?? '';
    _exerciseController.text = summary.exerciseMinutes?.toString() ?? '';
    return summary;
  }

  void _refresh() => setState(() => _todayFuture = _loadToday());

  @override
  void dispose() {
    _sleepController.dispose();
    _exerciseController.dispose();
    _sleepFocusNode.dispose();
    _exerciseFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveSleep() async {
    final hours = double.tryParse(_sleepController.text);
    if (hours == null || hours < 0 || hours > 24) return;
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    await LogService.upsertSleepRecord(userId: userId, hours: hours);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Sleep saved'), duration: Duration(seconds: 1)));
    _refresh();
  }

  Future<void> _saveExercise() async {
    final minutes = double.tryParse(_exerciseController.text);
    if (minutes == null || minutes < 0) return;
    final userId = AuthService.currentUserId;
    if (userId == null) return;
    await LogService.upsertExerciseRecord(userId: userId, minutes: minutes);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Exercise saved'), duration: Duration(seconds: 1)));
    _refresh();
  }

  Future<void> _openMealSheet(String mealType, String displayLabel) async {
    final entry = await showModalBottomSheet<_LogEntryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LogEntrySheet(label: displayLabel, collectAmount: false),
    );
    if (entry == null) return;

    final userId = AuthService.currentUserId;
    if (userId == null || !mounted) return;
    await LogService.insertFoodLog(
      userId: userId,
      mealType: mealType,
      description: entry.description,
    );
    _refresh();
  }

  Future<void> _openDrinkSheet() async {
    final entry = await showModalBottomSheet<_LogEntryResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _LogEntrySheet(label: 'Drinks', collectAmount: true),
    );
    if (entry == null) return;

    final userId = AuthService.currentUserId;
    if (userId == null || !mounted) return;
    await LogService.insertDrinkLog(
      userId: userId,
      description: entry.description,
      amountMl: entry.amountMl,
    );
    _refresh();
  }

  void _handleTabTap(int index) {
    if (index == 1) return; // already here
    final route = switch (index) {
      0 => MaterialPageRoute(builder: (_) => const DashboardPage()),
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
      appBar: AppBar(
        backgroundColor: scheme.primary,
        title: Text(
          'Daily Log',
          style: textTheme.headlineSmall?.copyWith(color: scheme.onPrimary),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<DailyLogSummary>(
          future: _todayFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorView(
                message: 'Could not load today\'s log: ${snapshot.error}',
                onLoggedOut: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                ),
              );
            }
            final today = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meal', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AddEntryRow(
                    label: 'Breakfast',
                    isLogged: today.hasBreakfast,
                    onTap: () => _openMealSheet('breakfast', 'Breakfast'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AddEntryRow(
                    label: 'Lunch',
                    isLogged: today.hasLunch,
                    onTap: () => _openMealSheet('lunch', 'Lunch'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AddEntryRow(
                    label: 'Dinner',
                    isLogged: today.hasDinner,
                    onTap: () => _openMealSheet('dinner', 'Dinner'),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Beverage', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AddEntryRow(
                    label: 'Drinks',
                    isLogged: today.drinkLogs.isNotEmpty,
                    onTap: _openDrinkSheet,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Sleep Duration', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Time',
                    hint: 'in Hours',
                    controller: _sleepController,
                    focusNode: _sleepFocusNode,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null; // optional
                      final hours = double.tryParse(value);
                      if (hours == null) return 'Enter a number';
                      if (hours < 0 || hours > 24) return '0–24 hours only';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Text('Exercise Duration', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Time',
                    hint: 'in Minutes',
                    controller: _exerciseController,
                    focusNode: _exerciseFocusNode,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null; // optional
                      final minutes = double.tryParse(value);
                      if (minutes == null) return 'Enter a number';
                      if (minutes < 0) return 'Must be 0 or more';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: _handleTabTap,
      ),
    );
  }
}

class _LogEntryResult {
  const _LogEntryResult({required this.description, this.amountMl});
  final String description;
  final double? amountMl;
}

/// The bottom sheet opened by tapping a meal/drink row. Runs the text
/// through Gemini before it's accepted — an inline error is shown instead
/// of closing the sheet if Gemini rejects it, so a bad entry never even
/// reaches the "insert into Supabase" step.
class _LogEntrySheet extends StatefulWidget {
  const _LogEntrySheet({required this.label, required this.collectAmount});

  final String label;
  final bool collectAmount;

  @override
  State<_LogEntrySheet> createState() => _LogEntrySheetState();
}

class _LogEntrySheetState extends State<_LogEntrySheet> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isValidating = false;
  String? _errorText;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final text = _descriptionController.text.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Enter what you had first');
      return;
    }

    setState(() {
      _isValidating = true;
      _errorText = null;
    });

    bool isValid;
    try {
      isValid = await GeminiService.validateFoodOrDrink(text);
    } on GeminiServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _isValidating = false;
        _errorText = e.message;
      });
      return;
    }

    if (!mounted) return;

    if (!isValid) {
      setState(() {
        _isValidating = false;
        _errorText = "That doesn't look like a food or drink — try again";
      });
      return;
    }

    Navigator.of(context).pop(
      _LogEntryResult(
        description: text,
        amountMl: widget.collectAmount ? double.tryParse(_amountController.text) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          AppTextField(
            label: 'What did you have?',
            hint: 'e.g. grilled chicken and rice',
            controller: _descriptionController,
          ),
          if (widget.collectAmount) ...[
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Amount (ml) — optional',
              hint: 'e.g. 250',
              controller: _amountController,
              keyboardType: TextInputType.number,
            ),
          ],
          if (_errorText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Save',
            isLoading: _isValidating,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
