import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../providers/attendance_providers.dart';
import '../../providers/auth_providers.dart';
import '../../router/app_routes.dart';

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  AttendanceStatus? _activeFilter;

  static final _dateFmt = DateFormat('EEE, d MMM yyyy', 'id');
  static final _timeFmt = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.attendanceHistory),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          final historyAsync = ref.watch(attendanceHistoryProvider(user.uid));
          return Column(
            children: [
              _FilterBar(
                active: _activeFilter,
                onChanged: (s) => setState(() => _activeFilter = s),
              ),
              Expanded(
                child: historyAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (records) {
                    final filtered = _activeFilter == null
                        ? records
                        : records
                            .where((r) =>
                                r.type == AttendanceType.clockIn &&
                                r.status == _activeFilter)
                            .toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_rounded,
                                size: 64, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(l10n.noRecords,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textMuted)),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final r = filtered[i];
                        return _HistoryTile(
                          record: r,
                          dateFmt: _dateFmt,
                          timeFmt: _timeFmt,
                          onTap: () => context.push(
                            AppRoutes.attendanceDetail,
                            extra: {'record': r},
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.active, required this.onChanged});
  final AttendanceStatus? active;
  final ValueChanged<AttendanceStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _Chip(
            label: l10n.all,
            active: active == null,
            color: AppColors.safetyOrange,
            onTap: () => onChanged(null),
          ),
          const SizedBox(width: 8),
          for (final status in AttendanceStatus.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: status.label,
                active: active == status,
                color: _statusColor(status),
                onTap: () => onChanged(status),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(AttendanceStatus s) => switch (s) {
        AttendanceStatus.hadir => AppColors.success,
        AttendanceStatus.telat => AppColors.warning,
        AttendanceStatus.izin => AppColors.info,
        AttendanceStatus.alpha => AppColors.danger,
      };
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.record,
    required this.dateFmt,
    required this.timeFmt,
    required this.onTap,
  });
  final AttendanceRecord record;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  final VoidCallback onTap;

  Color get _statusColor => switch (record.status) {
        AttendanceStatus.hadir => AppColors.success,
        AttendanceStatus.telat => AppColors.warning,
        AttendanceStatus.izin => AppColors.info,
        AttendanceStatus.alpha => AppColors.danger,
      };

  IconData get _typeIcon => record.type == AttendanceType.clockIn
      ? Icons.login_rounded
      : Icons.logout_rounded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_typeIcon, color: _statusColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.type == AttendanceType.clockIn
                          ? l10n.clockIn
                          : l10n.clockOut,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFmt.format(record.timestamp),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeFmt.format(record.timestamp),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  if (record.type == AttendanceType.clockIn)
                    _StatusPill(status: record.status, color: _statusColor),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});
  final AttendanceStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
