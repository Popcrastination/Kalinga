import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/add_entry_row.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'dashboard_page.dart';
import 'overview_page.dart';
import 'profile_page.dart';

class DailyLogPage extends StatefulWidget {
  const DailyLogPage({super.key});

  @override
  State<DailyLogPage> createState() => _DailyLogPageState();
}

class _DailyLogPageState extends State<DailyLogPage> {
  // TODO(data): this whole "isLogged" map is a UI-only stand-in. Once the
  // backend exists, this screen should instead read today's rows from
  // food_logs / drink_logs (Supabase) and derive these booleans from that,
  // rather than tracking them as local widget state.
  final Map<String, bool> _loggedState = {
    'Breakfast': true,
    'Lunch': false,
    'Dinner': false,
    'Drinks': false,
  };

  final _sleepController = TextEditingController();
  final _exerciseController = TextEditingController();

  @override
  void dispose() {
    _sleepController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _openEntrySheet(String label) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _LogEntrySheet(label: label),
    );

    // TODO(gemini): `result` is the raw text the user typed (e.g. "grilled
    // chicken and rice"). Before saving it, send it to the Gemini API to
    // confirm it's actually a food/drink entry:
    //   final isValid = await GeminiService.validateFoodOrDrink(result);
    //   if (!isValid) { show an error instead of marking it logged; return; }
    //
    // TODO(data): once validated, insert a row into `food_logs` or
    // `drink_logs` (Supabase) with meal_type/description/logged_at, instead
    // of just flipping a local boolean like this UI-only version does.
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _loggedState[label] = true);
    }
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
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meal', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AddEntryRow(
                label: 'Breakfast',
                isLogged: _loggedState['Breakfast']!,
                onTap: () => _openEntrySheet('Breakfast'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AddEntryRow(
                label: 'Lunch',
                isLogged: _loggedState['Lunch']!,
                onTap: () => _openEntrySheet('Lunch'),
              ),
              const SizedBox(height: AppSpacing.sm),
              AddEntryRow(
                label: 'Dinner',
                isLogged: _loggedState['Dinner']!,
                onTap: () => _openEntrySheet('Dinner'),
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Beverage', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              AddEntryRow(
                label: 'Drinks',
                isLogged: _loggedState['Drinks']!,
                onTap: () => _openEntrySheet('Drinks'),
              ),
              const SizedBox(height: AppSpacing.md),

              Text('Sleep Duration', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              // TODO(save trigger): there's no submit button on this screen
              // yet — once one exists (or an on-blur save), wrap this in a
              // Form/GlobalKey to actually run this validator before saving
              // to `sleep_records`.
              AppTextField(
                label: 'Time',
                hint: 'in Hours',
                controller: _sleepController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // optional for now
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null; // optional for now
                  final minutes = double.tryParse(value);
                  if (minutes == null) return 'Enter a number';
                  if (minutes < 0) return 'Must be 0 or more';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: _handleTabTap,
      ),
    );
  }
}

/// The bottom sheet opened by tapping a meal/drink row. Purely a text
/// input for now — [_DailyLogPageState._openEntrySheet] is where Gemini
/// validation and the Supabase insert get added later.
class _LogEntrySheet extends StatefulWidget {
  const _LogEntrySheet({required this.label});

  final String label;

  @override
  State<_LogEntrySheet> createState() => _LogEntrySheetState();
}

class _LogEntrySheetState extends State<_LogEntrySheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            controller: _controller,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Save',
            onPressed: () => Navigator.of(context).pop(_controller.text),
          ),
        ],
      ),
    );
  }
}
