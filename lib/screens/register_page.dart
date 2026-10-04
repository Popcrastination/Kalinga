import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_spacing.dart';
import '../services/auth_service.dart';
import '../utils/date_of_birth_formatter.dart';
import '../utils/date_validators.dart';
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

  /// No whitespace allowed — "john david" or "john david@example" should
  /// both be rejected. Also disallows characters that would make the
  /// synthetic-email trick in AuthService produce something invalid.
  String? _usernameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.contains(RegExp(r'\s'))) return 'No spaces allowed';
    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
      return 'Letters, numbers, underscore, and dot only';
    }
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

    try {
      await AuthService.signUp(
        username: _usernameController.text,
        password: _passwordController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _dobController.text,
        heightCm: double.parse(_heightController.text),
        weightKg: double.parse(_weightController.text),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: scheme.primary,
        leading: BackButton(color: scheme.onPrimary),
        // Logo lives in the AppBar itself now, not the body below it —
        // this is what puts it inside the green header, matching the
        // mockup, instead of floating in the cream area beneath it.
        title: Image.asset('assets/images/kalinga_logo.png', height: 32),
        centerTitle: true,
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

                AppTextField(
                  label: 'Username',
                  hint: 'Enter your username',
                  controller: _usernameController,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                  validator: _usernameValidator,
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
                        validator: DateValidators.dateOfBirth,
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
