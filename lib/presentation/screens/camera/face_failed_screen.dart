import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../router/app_routes.dart';

/// Shown when face detection validation fails on the captured photo.
/// Offers a retry (back to selfie camera) or cancel (back to dashboard).
class FaceFailedScreen extends StatelessWidget {
  const FaceFailedScreen({
    super.key,
    required this.attendanceType,
    required this.retryArgs,
  });

  final AttendanceType attendanceType;

  /// The full route args (GPS context) to re-pass to the camera on retry.
  final Map<String, dynamic> retryArgs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Failed icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.danger, width: 2.5),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.danger,
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.faceVerificationFailed,
                style: theme.textTheme.headlineMedium
                    ?.copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: 12),
              Text(
                'Foto tidak memenuhi syarat verifikasi. Pastikan:',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Checklist of what went wrong
              _TipCard(tips: const [
                'Hanya ada 1 wajah dalam frame',
                'Wajah berada di dalam oval panduan',
                'Pencahayaan cukup terang',
                'Gambar tidak blur atau terlalu gelap',
                'Hadap langsung ke kamera',
              ]),

              const Spacer(),

              // Retry
              ElevatedButton.icon(
                onPressed: () => context.pushReplacement(
                  AppRoutes.selfieCamera,
                  extra: retryArgs,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
              const SizedBox(height: 12),

              // Cancel
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.backToDashboard),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.navy500),
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tips});
  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy700,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: tips
            .map(
              (t) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_right_rounded,
                        color: AppColors.safetyOrange, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(t,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
