import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../router/app_routes.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  const EmployeeDetailScreen({super.key, required this.user});
  final AppUser user;

  @override
  ConsumerState<EmployeeDetailScreen> createState() =>
      _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  late UserRole _selectedRole;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  Future<void> _saveRole() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(widget.user.uid)
          .update({'role': _selectedRole.name});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Role berhasil diperbarui')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final ok = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(widget.user.email);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok == null
            ? 'Email reset password terkirim ke ${widget.user.email}'
            : 'Gagal: $ok'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final u = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Karyawan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            tooltip: 'Log Absensi',
            onPressed: () => context.push(
              AppRoutes.adminAttendanceLogs,
              extra: {'userId': u.uid, 'userName': u.name},
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Identity card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        AppColors.safetyOrange.withValues(alpha: 0.15),
                    backgroundImage: u.photoUrl != null
                        ? NetworkImage(u.photoUrl!)
                        : null,
                    child: u.photoUrl == null
                        ? Text(u.initials,
                            style: const TextStyle(
                                color: AppColors.safetyOrange,
                                fontSize: 24,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(u.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _Row(label: 'NIK', value: u.nik.isEmpty ? '-' : u.nik),
                  _Row(label: 'Email', value: u.email),
                  if (u.department != null)
                    _Row(label: 'Departemen', value: u.department!),
                  if (u.position != null)
                    _Row(label: 'Jabatan', value: u.position!),
                  if (u.phoneNumber != null)
                    _Row(label: 'Telepon', value: u.phoneNumber!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Role editor
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Role', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
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
                              selected: _selectedRole == role,
                              onSelected: (_) =>
                                  setState(() => _selectedRole = role),
                              selectedColor:
                                  AppColors.safetyOrange.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ||
                              _selectedRole == widget.user.role
                          ? null
                          : _saveRole,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Simpan Role'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Admin actions
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded,
                      color: AppColors.warning),
                  title: const Text('Reset Password'),
                  subtitle: const Text('Kirim email reset ke karyawan'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  onTap: _sendPasswordReset,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
