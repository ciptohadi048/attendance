import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/admin_providers.dart';
import '../../router/app_routes.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeeListProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Karyawan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Tambah Karyawan',
            onPressed: () => context.push(AppRoutes.adminCreateUser),
          ),
        ],
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (employees) {
          if (employees.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Belum ada karyawan',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: employees.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final emp = employees[i];
              return _EmployeeTile(
                user: emp,
                onTap: () => context.push(
                  AppRoutes.adminEmployeeDetail,
                  extra: {'user': emp},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.user, required this.onTap});
  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAdmin = user.role == UserRole.admin;
    final roleColor = isAdmin ? AppColors.safetyOrange : AppColors.info;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.safetyOrange.withValues(alpha: 0.15),
          backgroundImage:
              user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
          child: user.photoUrl == null
              ? Text(user.initials,
                  style: const TextStyle(
                      color: AppColors.safetyOrange,
                      fontWeight: FontWeight.bold))
              : null,
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.nik.isEmpty ? user.email : user.nik,
                style: theme.textTheme.bodySmall),
            if (user.department != null)
              Text(user.department!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: roleColor),
          ),
          child: Text(
            isAdmin ? 'Admin' : 'Karyawan',
            style: TextStyle(
                color: roleColor, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
