import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/gps_status.dart';

/// Pill-shaped badge showing "In Area ✓" (green) or "Outside Area ✗" (red).
/// Used on the GPS Validation screen and the Dashboard.
class GpsStatusBadge extends StatelessWidget {
  const GpsStatusBadge({super.key, required this.status});

  final GpsStatus status;

  @override
  Widget build(BuildContext context) {
    final inArea = status.isInArea;
    final color = inArea ? AppColors.success : AppColors.danger;
    final label = inArea ? 'In Area' : 'Outside Area';
    final icon = inArea ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small dot indicator (for compact use like the dashboard card).
class GpsStatusDot extends StatelessWidget {
  const GpsStatusDot({super.key, required this.isInArea});
  final bool isInArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isInArea ? AppColors.success : AppColors.danger,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isInArea ? AppColors.success : AppColors.danger)
                .withValues(alpha: 0.4),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}
