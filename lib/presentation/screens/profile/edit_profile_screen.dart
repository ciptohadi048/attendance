import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _posCtrl;
  late final TextEditingController _phoneCtrl;

  bool _loading = false;
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _user = ref.read(authStateProvider).value;
    _nameCtrl = TextEditingController(text: _user?.name ?? '');
    _deptCtrl = TextEditingController(text: _user?.department ?? '');
    _posCtrl = TextEditingController(text: _user?.position ?? '');
    _phoneCtrl = TextEditingController(text: _user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    _posCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final uid = _user?.uid;
      if (uid == null) return;

      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({
        'name': _nameCtrl.text.trim(),
        'department': _deptCtrl.text.trim().isEmpty
            ? null
            : _deptCtrl.text.trim(),
        'position':
            _posCtrl.text.trim().isEmpty ? null : _posCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim().isEmpty
            ? null
            : _phoneCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
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
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      label: 'Nama Lengkap',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _deptCtrl,
                      label: 'Departemen',
                      prefixIcon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _posCtrl,
                      label: 'Jabatan',
                      prefixIcon: Icons.work_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _phoneCtrl,
                      label: 'Nomor Telepon',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Simpan Perubahan',
              isLoading: _loading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
