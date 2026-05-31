import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/attendance_providers.dart';
import '../../providers/auth_providers.dart';
import '../../router/app_routes.dart';
import '../../widgets/user_app_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authStateProvider);

    return Scaffold(
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return _DashboardBody(user: user);
        },
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayAttendanceProvider);

    return Column(
      children: [
        UserAppBar(user: user),
        Expanded(
          child: todayAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (records) => ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _ClockCard(user: user, records: records),
                const SizedBox(height: 16),
                _SectionTitle(context.l10n.weeklyStats),
                const SizedBox(height: 12),
                _WeeklyStatsRow(records: records),
                const SizedBox(height: 24),
                _SectionTitle(context.l10n.menu),
                const SizedBox(height: 12),
                const _QuickActionsGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Clock-in / clock-out card
// ---------------------------------------------------------------------------

class _ClockCard extends StatelessWidget {
  const _ClockCard({required this.user, required this.records});

  final AppUser user;
  final List<AttendanceRecord> records;

  AttendanceRecord? get _clockIn => records
      .where((r) => r.type == AttendanceType.clockIn)
      .firstOrNull;

  AttendanceRecord? get _clockOut => records
      .where((r) => r.type == AttendanceType.clockOut)
      .firstOrNull;

  bool get _hasClockedIn => _clockIn != null;
  bool get _hasClockedOut => _clockOut != null;

  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    color: AppColors.safetyOrange),
                const SizedBox(width: 8),
                Text(l10n.todayAttendance, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 16),

            // Clock-in row
            _AttendanceTimeRow(
              label: l10n.clockIn,
              time: _hasClockedIn ? _timeFmt.format(_clockIn!.timestamp) : '--:--',
              status: _hasClockedIn ? _clockIn!.status : null,
              done: _hasClockedIn,
            ),
            const SizedBox(height: 8),

            // Clock-out row
            _AttendanceTimeRow(
              label: l10n.clockOut,
              time: _hasClockedOut
                  ? _timeFmt.format(_clockOut!.timestamp)
                  : '--:--',
              done: _hasClockedOut,
            ),
            const SizedBox(height: 20),

            // Action button
            if (!_hasClockedIn)
              _ClockButton(
                label: l10n.clockIn,
                icon: Icons.login_rounded,
                color: AppColors.success,
                attendanceType: AttendanceType.clockIn,
              )
            else if (!_hasClockedOut)
              _ClockButton(
                label: l10n.clockOut,
                icon: Icons.logout_rounded,
                color: AppColors.danger,
                attendanceType: AttendanceType.clockOut,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.navy600,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Text(l10n.attendanceComplete,
                        style: const TextStyle(color: AppColors.success)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceTimeRow extends StatelessWidget {
  const _AttendanceTimeRow({
    required this.label,
    required this.time,
    required this.done,
    this.status,
  });

  final String label;
  final String time;
  final bool done;
  final AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          color: done ? AppColors.success : AppColors.textMuted,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodyMedium),
        const Spacer(),
        Text(
          time,
          style: theme.textTheme.titleMedium?.copyWith(
            color: done ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        if (status != null) ...[
          const SizedBox(width: 8),
          _StatusPill(status: status!),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      AttendanceStatus.hadir => AppColors.success,
      AttendanceStatus.telat => AppColors.warning,
      AttendanceStatus.izin => AppColors.info,
      AttendanceStatus.alpha => AppColors.danger,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ClockButton extends StatelessWidget {
  const _ClockButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.attendanceType,
  });

  final String label;
  final IconData icon;
  final Color color;
  final AttendanceType attendanceType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => context.push(
          AppRoutes.gpsValidation,
          extra: {'attendanceType': attendanceType},
        ),
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly stats row
// ---------------------------------------------------------------------------

class _WeeklyStatsRow extends StatelessWidget {
  const _WeeklyStatsRow({required this.records});
  final List<AttendanceRecord> records;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hadir = records
        .where((r) =>
            r.type == AttendanceType.clockIn &&
            r.status == AttendanceStatus.hadir)
        .length;
    final telat = records
        .where((r) =>
            r.type == AttendanceType.clockIn &&
            r.status == AttendanceStatus.telat)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
              label: l10n.statusHadir, value: '$hadir', color: AppColors.success),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
              label: l10n.statusTelat, value: '$telat', color: AppColors.warning),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              _StatCard(label: l10n.statusAlpha, value: '0', color: AppColors.danger),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            Text(value,
                style:
                    theme.textTheme.headlineMedium?.copyWith(color: color)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick actions grid
// ---------------------------------------------------------------------------

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actions = [
      (Icons.history_rounded, l10n.history, AppRoutes.attendanceHistory),
      (Icons.notifications_outlined, l10n.notifications, AppRoutes.notifications),
      (Icons.person_outline_rounded, l10n.profile, AppRoutes.profile),
      (Icons.map_outlined, l10n.location, AppRoutes.employeeLocation),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        for (final (icon, label, route) in actions)
          Card(
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () => context.push(route),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.safetyOrange),
                  const SizedBox(height: 6),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleMedium);
}
