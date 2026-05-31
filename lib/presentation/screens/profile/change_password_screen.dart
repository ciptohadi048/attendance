import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/primary_button.dart';

/// Submits a password reset request to the admin via Firestore.
/// Admin reviews it and resets the password via the admin panel or web console.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  bool _loading = false;
  bool _done = false;

  Future<void> _submitRequest() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi habis. Silakan login ulang.')),
      );
      return;
    }
    setState(() => _loading = true);
    // Save messenger before async gap to avoid defunct-context assertion.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.passwordResetRequestsCollection)
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'userName': user.name,
        'email': user.email,
        'nik': user.nik,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      if (mounted) setState(() => _done = true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Gagal mengirim permintaan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _done ? _SuccessView() : _RequestView(
          loading: _loading,
          onSubmit: _submitRequest,
        ),
      ),
    );
  }
}

class _RequestView extends StatelessWidget {
  const _RequestView({required this.loading, required this.onSubmit});
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_reset_rounded,
            size: 64, color: AppColors.safetyOrange),
        const SizedBox(height: 24),
        Text(
          'Permintaan Reset Password',
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Permintaan akan dikirim ke Admin HRD.\n'
          'Admin akan mengatur ulang password Anda melalui sistem web.\n'
          'Anda akan dihubungi setelah password diperbarui.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          label: 'Kirim Permintaan ke Admin',
          isLoading: loading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.success, size: 44),
        ),
        const SizedBox(height: 24),
        Text(
          'Permintaan Terkirim!',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: AppColors.success),
        ),
        const SizedBox(height: 12),
        Text(
          'Admin HRD akan segera memproses permintaan Anda.\n'
          'Harap tunggu konfirmasi dari admin.',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kembali'),
        ),
      ],
    );
  }
}
