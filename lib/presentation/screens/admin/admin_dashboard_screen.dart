import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import '../../router/app_routes.dart';
import '../../widgets/user_app_bar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authStateProvider);
    final statsAsync = ref.watch(adminStatsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return Column(
            children: [
              UserAppBar(user: user, subtitle: 'Admin HRD'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Text('Ringkasan Hari Ini',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    statsAsync.when(
                      skipLoadingOnRefresh: true,
                      skipLoadingOnReload: true,
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.cloud_off_rounded,
                                  color: AppColors.warning, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                e.toString().contains('building')
                                    ? 'Index Firestore sedang dibangun.\nTunggu 1-3 menit lalu refresh.'
                                    : 'Gagal memuat: ${e.toString().split(']').last.trim()}',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () =>
                                    ref.invalidate(todayAllAttendanceProvider),
                                icon: const Icon(Icons.refresh_rounded,
                                    size: 16),
                                label: const Text('Refresh'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      data: (stats) => Column(
                        children: [
                          Row(children: [
                            Expanded(
                                child: _AdminStat(
                                    label: 'Hadir',
                                    value: '${stats.hadir}',
                                    icon: Icons.check_circle_outline,
                                    color: AppColors.success)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _AdminStat(
                                    label: 'Telat',
                                    value: '${stats.telat}',
                                    icon: Icons.timer_outlined,
                                    color: AppColors.warning)),
                          ]),
                          const SizedBox(height: 12),
                          Row(children: [
                            Expanded(
                                child: _AdminStat(
                                    label: 'Alpha',
                                    value: '${stats.alpha}',
                                    icon: Icons.cancel_outlined,
                                    color: AppColors.danger)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: _AdminStat(
                                    label: 'Karyawan',
                                    value: '${stats.totalKaryawan}',
                                    icon: Icons.groups_outlined,
                                    color: AppColors.info)),
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Menu Admin', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _MenuCard(
                      icon: Icons.people_rounded,
                      title: 'Daftar Karyawan',
                      subtitle: 'Lihat & kelola karyawan',
                      onTap: () => context.push(AppRoutes.adminEmployeeList),
                    ),
                    const SizedBox(height: 8),
                    _MenuCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'KPI Charts',
                      subtitle: 'Weekly attendance & late trend',
                      onTap: () => context.push(AppRoutes.adminKpiCharts),
                    ),
                    const SizedBox(height: 8),
                    _MenuCard(
                      icon: Icons.list_alt_rounded,
                      title: 'Log Absensi',
                      subtitle: 'Filter & export data absensi',
                      onTap: () => context.push(AppRoutes.adminAttendanceLogs),
                    ),
                    const SizedBox(height: 8),
                    _MenuCard(
                      icon: Icons.map_rounded,
                      title: 'Peta Clock-In',
                      subtitle: 'Lokasi karyawan hari ini',
                      onTap: () => context.push(AppRoutes.adminMap),
                    ),
                    const SizedBox(height: 8),
                    _MenuCard(
                      icon: Icons.person_add_rounded,
                      title: 'Tambah Karyawan',
                      subtitle: 'Buat akun karyawan baru',
                      color: AppColors.safetyOrange,
                      onTap: () => context.push(AppRoutes.adminCreateUser),
                    ),
                    const SizedBox(height: 8),
                    _MenuCard(
                      icon: Icons.lock_reset_rounded,
                      title: 'Request Reset Password',
                      subtitle: 'Permintaan reset dari karyawan',
                      color: AppColors.warning,
                      onTap: () =>
                          context.push(AppRoutes.adminPasswordRequests),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  const _AdminStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.titleLarge),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.safetyOrange),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
