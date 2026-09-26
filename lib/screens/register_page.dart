import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_spacing.dart';
import '../utils/date_of_birth_formatter.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';
import 'dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) =>
      (value == null || value.trim().isEmpty) ? 'This field is required' : null;

  String? _dobValidator(String? value) {
    if (value == null || value.isEmpty) return 'Date of birth is required';
    final regex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (!regex.hasMatch(value)) return 'Use MM/DD/YYYY';
    return null;
  }

  String? _numberValidator(String? value, {required String label}) {
    if (value == null || value.isEmpty) return '$label is required';
    if (double.tryParse(value) == null) return '$label must be a number';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO(auth + data): replace with real Supabase calls, roughly:
    //   final res = await supabase.auth.signUp(
    //     email: _usernameController.text, // or a dedicated email field
    //     password: _passwordController.text,
    //   );
    //   await supabase.from('profiles').insert({
    //     'id': res.user!.id,
    //     'username': _usernameController.text,
    //     'first_name': _firstNameController.text,
    //     'last_name': _lastNameController.text,
    //     'date_of_birth': _dobController.text,
    //     'height_cm': double.parse(_heightController.text),
    //     'weight_kg': double.parse(_weightController.text),
    //   });
    // Row Level Security on `profiles` should restrict each row to its
    // own authenticated user — see the design system's storage decision.
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
      appBar: AppBar(
        backgroundColor: scheme.primary,
        leading: const BackButton(color: Colors.white),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Kalinga',
                  style: textTheme.headlineSmall?.copyWith(color: scheme.primary),
                ),
                const SizedBox(height: 24),

                AppTextField(
                  label: 'Username',
                  hint: 'Enter your username',
                  controller: _usernameController,
                  validator: _requiredValidator,
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'First Name',
                        hint: 'Enter your first name',
                        controller: _firstNameController,
                        validator: _requiredValidator,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Last Name',
                        hint: 'Enter your last name',
                        controller: _lastNameController,
                        validator: _requiredValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: 'Date of Birth',
                        hint: 'MM/DD/YYYY',
                        controller: _dobController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          DateOfBirthFormatter(),
                        ],
                        validator: _dobValidator,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Height',
                        hint: 'in cm',
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _numberValidator(v, label: 'Height'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Weight',
                        hint: 'in kg',
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        validator: (v) => _numberValidator(v, label: 'Weight'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Confirm your password',
                  hint: 'Enter your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: _confirmPasswordValidator,
                ),
                const SizedBox(height: AppSpacing.lg),

                PrimaryButton(
                  label: 'Create Account',
                  onPressed: _handleCreateAccount,
                  isLoading: _isLoading,
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
