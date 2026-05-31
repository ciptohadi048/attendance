import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/attendance_record.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key, required this.record});
  final AttendanceRecord record;

  static final _fullFmt = DateFormat('EEEE, d MMMM yyyy — HH:mm:ss', 'id');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isClockIn = record.type == AttendanceType.clockIn;
    final statusColor = switch (record.status) {
      AttendanceStatus.hadir => AppColors.success,
      AttendanceStatus.telat => AppColors.warning,
      AttendanceStatus.izin => AppColors.info,
      AttendanceStatus.alpha => AppColors.danger,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(isClockIn ? 'Detail Clock In' : 'Detail Clock Out'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status banner
          if (isClockIn)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.circle, color: statusColor, size: 10),
                  const SizedBox(width: 8),
                  Text(
                    record.status.label,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Selfie card
          if (record.selfieUrl != null) ...[
            Card(
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        const Icon(Icons.face_rounded,
                            color: AppColors.safetyOrange, size: 20),
                        const SizedBox(width: 8),
                        Text('Foto Selfie',
                            style: theme.textTheme.titleSmall),
                      ],
                    ),
                  ),
                  Image.network(
                    record.selfieUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 100,
                      child: Center(
                          child: Icon(Icons.broken_image_rounded,
                              color: AppColors.textMuted)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Waktu',
                    value: _fullFmt.format(record.timestamp),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.location_on_rounded,
                    label: 'Koordinat',
                    value:
                        '${record.latitude.toStringAsFixed(6)}, ${record.longitude.toStringAsFixed(6)}',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.social_distance_rounded,
                    label: 'Jarak dari Kantor',
                    value:
                        '${record.distanceFromOffice.toStringAsFixed(0)} m',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: record.isInArea
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    label: 'Status Area',
                    value: record.isInArea ? 'Dalam Area' : 'Luar Area',
                    valueColor:
                        record.isInArea ? AppColors.success : AppColors.danger,
                    iconColor:
                        record.isInArea ? AppColors.success : AppColors.danger,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            color: iconColor ?? AppColors.safetyOrange, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
