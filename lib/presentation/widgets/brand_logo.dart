import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The app's logo mark: a rounded "safety orange" tile with a factory icon.
/// Reused on the splash and login screens so branding stays consistent.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.safetyOrange, AppColors.orange600],
        ),
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: AppColors.safetyOrange.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.factory_rounded,
        color: AppColors.white,
        size: size * 0.52,
      ),
    );
  }
}
