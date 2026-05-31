import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../router/app_routes.dart';

/// Shown after a successful selfie + face validation.
/// Displays the captured selfie, the timestamp, and the GPS status,
/// then navigates back to the dashboard.
class FaceSuccessScreen extends StatelessWidget {
  const FaceSuccessScreen({
    super.key,
    required this.attendanceType,
    this.selfieFile,
    this.record,
  });

  final AttendanceType attendanceType;
  final File? selfieFile;
  final AttendanceRecord? record;

  static final _timeFmt = DateFormat('HH:mm:ss');
  static final _dateFmt = DateFormat('EEEE, d MMMM yyyy', 'id');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isClockIn = attendanceType == AttendanceType.clockIn;
    final now = record?.timestamp ?? DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.success, width: 2.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.success,
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                isClockIn ? l10n.clockInSuccess : l10n.clockOutSuccess,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: AppColors.success),
              ),
              const SizedBox(height: 8),
              Text(
                'Absensi Anda telah tercatat.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Selfie preview
              if (selfieFile != null)
                ClipOval(
                  child: Image.file(
                    selfieFile!,
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 24),

              // Timestamp card
              _InfoCard(children: [
                _InfoRow(
                  icon: Icons.access_time_rounded,
                  label: l10n.time,
                  value: _timeFmt.format(now),
                ),
                const Divider(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.date,
                  value: _dateFmt.format(now),
                ),
                if (record != null) ...[
                  const Divider(height: 16),
                  _InfoRow(
                    icon: Icons.place_rounded,
                    label: l10n.location,
                    value: l10n.distanceFromOffice(
                        '${record!.distanceFromOffice.toStringAsFixed(0)} m'),
                  ),
                  const Divider(height: 16),
                  _InfoRow(
                    icon: record!.isInArea
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    label: 'GPS',
                    value: record!.isInArea ? l10n.inArea : l10n.outsideArea,
                    valueColor:
                        record!.isInArea ? AppColors.success : AppColors.danger,
                  ),
                  const Divider(height: 16),
                  _InfoRow(
                    icon: Icons.badge_rounded,
                    label: l10n.status,
                    value: record!.status.label,
                    valueColor: record!.status == AttendanceStatus.hadir
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ]),

              const Spacer(),

              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.backToDashboard),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.safetyOrange),
        const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodySmall),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
