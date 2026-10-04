import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../services/auth_service.dart';

/// Shown whenever a screen's data fetch fails. Always includes a Log out
/// option — without this, a broken fetch (e.g. a missing table) traps a
/// signed-in user with no way back to Login, since every other screen's
/// Logout button lives behind the same fetch that just failed.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onLoggedOut});

  final String message;
  final VoidCallback onLoggedOut;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () async {
                await AuthService.signOut();
                onLoggedOut();
              },
              child: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
