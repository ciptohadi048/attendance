import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _posCtrl = TextEditingController();
  UserRole _role = UserRole.employee;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nikCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _deptCtrl.dispose();
    _posCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      // Create Firebase Auth user.
      // Use a secondary FirebaseAuth instance to avoid signing out the admin.
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      // Write Firestore profile.
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(cred.user!.uid)
          .set({
        'nik': _nikCtrl.text.trim(),
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'role': _role.name,
        'department': _deptCtrl.text.trim().isEmpty
            ? null
            : _deptCtrl.text.trim(),
        'position': _posCtrl.text.trim().isEmpty
            ? null
            : _posCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Akun ${_nameCtrl.text.trim()} berhasil dibuat')),
        );
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final msg = switch (e.code) {
          'email-already-in-use' => 'Email sudah terdaftar',
          'weak-password' => 'Password terlalu lemah (min. 6 karakter)',
          'invalid-email' => 'Format email tidak valid',
          _ => e.message ?? 'Terjadi kesalahan',
        };
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi email terlebih dahulu')),
      );
      return;
    }
    final err = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            err == null ? 'Email reset terkirim ke $email' : 'Gagal: $err'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Karyawan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informasi Pribadi',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Nama Lengkap',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _nikCtrl,
                      label: 'NIK',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Wajib diisi'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _deptCtrl,
                      label: 'Departemen',
                      prefixIcon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _posCtrl,
                      label: 'Jabatan',
                      prefixIcon: Icons.work_outline_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Akun & Akses',
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Wajib diisi';
                        }
                        if (!v.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _passCtrl,
                      label: 'Password Sementara',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      suffix: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v.length < 6) return 'Min. 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Role', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final role in UserRole.values)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(role == UserRole.admin
                                    ? 'Admin'
                                    : 'Karyawan'),
                                selected: _role == role,
                                onSelected: (_) =>
                                    setState(() => _role = role),
                                selectedColor: AppColors.safetyOrange
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Buat Akun',
              isLoading: _loading,
              onPressed: _create,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _sendReset,
              icon: const Icon(Icons.lock_reset_rounded),
              label: const Text('Kirim Email Reset Password'),
            ),
          ],
        ),
      ),
    );
  }
}
