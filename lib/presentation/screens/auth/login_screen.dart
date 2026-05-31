import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/primary_button.dart';

/// Login screen: NIK/email + password, Remember Me, and Forgot Password.
///
/// Routing after a successful sign-in is handled centrally by the go_router
/// redirect watching [authStateProvider] — this screen only triggers the
/// action and surfaces loading/error feedback.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill the saved identifier if "Remember Me" was used previously.
    final prefs = ref.read(sharedPrefsServiceProvider);
    _rememberMe = prefs.rememberMe;
    if (_rememberMe && prefs.savedIdentifier != null) {
      _identifierController.text = prefs.savedIdentifier!;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authControllerProvider.notifier).signIn(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          rememberMe: _rememberMe,
        );

    if (!ok && mounted) {
      final error = ref.read(authControllerProvider).error;
      _showSnack(_errorText(error));
    }
    // On success, the router redirect takes over automatically.
  }

  Future<void> _forgotPassword() async {
    final l10n = context.l10n;
    final nikCtrl = TextEditingController(
      text: _identifierController.text.contains('@')
          ? ''
          : _identifierController.text,
    );
    final nameCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.forgotPasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.forgotPasswordDesc),
            const SizedBox(height: 16),
            TextField(
              controller: nikCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: l10n.nik, labelText: l10n.nik),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                  hintText: l10n.fullName, labelText: l10n.name),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.sendToAdmin),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final nik = nikCtrl.text.trim();
    final name = nameCtrl.text.trim();
    if (nik.isEmpty || name.isEmpty) {
      _showSnack(l10n.nikAndNameRequired);
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('password_reset_requests')
          .doc('nik_$nik')
          .set({
        'userId': '',
        'userName': name,
        'email': '',
        'nik': nik,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      if (!mounted) return;
      _showSnack(l10n.requestSent);
    } catch (e) {
      if (!mounted) return;
      _showSnack(l10n.requestFailed(e.toString()));
    }
  }

  String _errorText(Object? error) {
    return error?.toString() ?? context.l10n.loginFailed;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: BrandLogo(size: 76),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.welcome,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 36),
                    AppTextField(
                      controller: _identifierController,
                      label: l10n.nikOrEmail,
                      hint: l10n.nikOrEmailHint,
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.identifier,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 18),
                    AppTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      hint: l10n.passwordHint,
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _submit(),
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.safetyOrange,
                          onChanged: isLoading
                              ? null
                              : (v) => setState(() => _rememberMe = v ?? false),
                        ),
                        Text(l10n.rememberMe),
                        const Spacer(),
                        TextButton(
                          onPressed: isLoading ? null : _forgotPassword,
                          child: Text(l10n.forgotPassword),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: l10n.login,
                      icon: Icons.login_rounded,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.contactHrd,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
