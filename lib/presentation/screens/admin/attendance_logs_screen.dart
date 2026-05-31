import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../providers/admin_providers.dart';

class AttendanceLogsScreen extends ConsumerStatefulWidget {
  const AttendanceLogsScreen({
    super.key,
    this.presetUserId,
    this.presetUserName,
  });
  final String? presetUserId;
  final String? presetUserName;

  @override
  ConsumerState<AttendanceLogsScreen> createState() =>
      _AttendanceLogsScreenState();
}

class _AttendanceLogsScreenState
    extends ConsumerState<AttendanceLogsScreen> {
  DateTime? _from;
  DateTime? _to;
  bool _exporting = false;

  static final _dateFmt = DateFormat('d MMM yyyy', 'id');
  static final _fullFmt = DateFormat('d MMM yyyy HH:mm', 'id');

  @override
  void initState() {
    super.initState();
    if (widget.presetUserId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(attendanceFilterProvider.notifier).update(
              AttendanceFilter(userId: widget.presetUserId),
            );
      });
    }
  }

  @override
  void dispose() {
    ref.read(attendanceFilterProvider.notifier).clear();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_from ?? DateTime.now())
          : (_to ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
      } else {
        _to = picked;
      }
    });
    ref.read(attendanceFilterProvider.notifier).update(
          AttendanceFilter(
            userId: widget.presetUserId ??
                ref.read(attendanceFilterProvider).userId,
            from: _from,
            to: _to,
          ),
        );
  }

  Future<void> _export(List<AttendanceRecord> records, Rect? origin) async {
    setState(() => _exporting = true);
    // Save messenger before async gap — avoids defunct context assertion.
    final messenger = ScaffoldMessenger.of(context);
    try {
      final employees = ref.read(employeeListProvider).value ?? [];
      final empMap = {for (final e in employees) e.uid: e.name};

      final rows = [
        ['Nama', 'NIK', 'Tanggal', 'Tipe', 'Waktu', 'Status', 'Jarak (m)', 'In Area'],
        ...records.map((r) => [
              empMap[r.userId] ?? r.userId,
              '',
              _dateFmt.format(r.timestamp),
              r.type == AttendanceType.clockIn ? 'Clock In' : 'Clock Out',
              DateFormat('HH:mm:ss').format(r.timestamp),
              r.status.label,
              r.distanceFromOffice.toStringAsFixed(0),
              r.isInArea ? 'Ya' : 'Tidak',
            ]),
      ];

      final csv = const ListToCsvConverter().convert(rows);
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/absensi_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Export Absensi',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export gagal: $e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(filteredAttendanceProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.presetUserName != null
            ? 'Log: ${widget.presetUserName}'
            : 'Log Absensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (logsAsync.value?.isNotEmpty == true)
            _exporting
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : Builder(
                    builder: (btnCtx) => IconButton(
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Export CSV',
                      onPressed: () {
                        final box = btnCtx.findRenderObject() as RenderBox?;
                        Rect? origin;
                        if (box != null && box.hasSize) {
                          origin = box.localToGlobal(Offset.zero) & box.size;
                        }
                        _export(logsAsync.value!, origin);
                      },
                    ),
                  ),
        ],
      ),
      body: Column(
        children: [
          // Date filter bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: _DateChip(
                    label: _from == null
                        ? 'Dari tanggal'
                        : _dateFmt.format(_from!),
                    onTap: () => _pickDate(true),
                    active: _from != null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DateChip(
                    label: _to == null
                        ? 'Sampai tanggal'
                        : _dateFmt.format(_to!),
                    onTap: () => _pickDate(false),
                    active: _to != null,
                  ),
                ),
                if (_from != null || _to != null)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      setState(() {
                        _from = null;
                        _to = null;
                      });
                      ref
                          .read(attendanceFilterProvider.notifier)
                          .update(AttendanceFilter(
                              userId: widget.presetUserId));
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: logsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (records) {
                if (records.isEmpty) {
                  return Center(
                    child: Text('Tidak ada data',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textMuted)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final r = records[i];
                    final employees =
                        ref.watch(employeeListProvider).value ?? [];
                    final emp = employees
                        .where((e) => e.uid == r.userId)
                        .firstOrNull;
                    final statusColor = switch (r.status) {
                      AttendanceStatus.hadir => AppColors.success,
                      AttendanceStatus.telat => AppColors.warning,
                      AttendanceStatus.izin => AppColors.info,
                      AttendanceStatus.alpha => AppColors.danger,
                    };
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          r.type == AttendanceType.clockIn
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          color: statusColor,
                        ),
                        title: Text(emp?.name ?? r.userId),
                        subtitle: Text(_fullFmt.format(r.timestamp)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              r.type == AttendanceType.clockIn
                                  ? 'Clock In'
                                  : 'Clock Out',
                              style: theme.textTheme.labelSmall,
                            ),
                            if (r.type == AttendanceType.clockIn)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  r.status.label,
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip(
      {required this.label, required this.onTap, required this.active});
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.safetyOrange.withValues(alpha: 0.15)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                active ? AppColors.safetyOrange : AppColors.textMuted,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 14,
                color: active
                    ? AppColors.safetyOrange
                    : AppColors.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 12,
                    color: active
                        ? AppColors.safetyOrange
                        : AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
