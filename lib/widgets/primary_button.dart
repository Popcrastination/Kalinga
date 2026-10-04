import 'package:flutter/material.dart';

/// The app's single filled-button style — a rounded, full-width button
/// used for the main action on a screen (Login, Create Account, etc.).
///
/// Takes only data and a callback; it never manages its own state.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Set true while an async call (e.g. a Supabase sign-in) is in flight.
  /// The button disables itself and shows a spinner instead of the label.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: onPrimary,
              ),
            )
          : Text(label),
    );
  }
}
