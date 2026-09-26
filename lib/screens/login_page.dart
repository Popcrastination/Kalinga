import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'register_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO(auth): replace this whole block with a real Supabase call:
    //   try {
    //     await supabase.auth.signInWithPassword(
    //       email: _usernameController.text,
    //       password: _passwordController.text,
    //     );
    //   } on AuthException catch (e) {
    //     // show e.message in a SnackBar instead of navigating
    //   }
    //
    // TODO(state management): once more than this screen needs to know
    // "is a user logged in," move auth status out of local setState and
    // into a Provider/Riverpod (or similar) AuthController that the
    // whole app can read from.
    await Future.delayed(const Duration(milliseconds: 600)); // placeholder

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),

                // --- Kalinga wordmark placeholder -----------------------
                // No brand asset exists yet — swap for the real logo once
                // it does, e.g. Image.asset('assets/images/logo.png').
                Row(
                  children: [
                    Icon(Icons.eco, color: scheme.primary, size: 32),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Kalinga',
                      style: textTheme.headlineSmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                AppTextField(
                  label: 'Username',
                  hint: 'Enter your username',
                  controller: _usernameController,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Username is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Password is required'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),

                PrimaryButton(
                  label: 'Login',
                  onPressed: _handleLogin,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppSpacing.md),

                Center(child: Text('or', style: textTheme.labelSmall)),
                const SizedBox(height: AppSpacing.md),

                // Register is a secondary, outlined action that only
                // appears on this one screen, so — per the design
                // system's own rule ("only define a component if a
                // screen actually needs it") — it doesn't get its own
                // widget file. A plain OutlinedButton is enough.
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: BorderSide(color: scheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: Text('Register', style: TextStyle(color: scheme.primary)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
