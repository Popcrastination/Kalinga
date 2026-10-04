import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';
import '../services/auth_service.dart';
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

    try {
      await AuthService.signIn(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    } on AuthServiceException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

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

                // --- Kalinga wordmark ------------------------------------
                Center(
                  child: Image.asset(
                    'assets/images/kalinga_logo.png',
                    height: 64,
                  ),
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
