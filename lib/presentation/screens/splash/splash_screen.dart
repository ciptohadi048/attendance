import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../router/app_routes.dart';
import '../../widgets/brand_logo.dart';

/// Branded loading screen shown on launch. While the logo animates in, it waits
/// for two things in parallel: a minimum display time (so branding doesn't
/// flash) and the first emission of the auth state. It then routes the user to
/// the admin shell, the employee dashboard, or the login screen.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Resolve the first auth value while enforcing a minimum branding time.
    final user = (await Future.wait([
      ref.read(authStateProvider.future),
      Future<void>.delayed(AppConstants.splashDuration),
    ]))
        .first as AppUser?;

    if (!mounted) return;
    if (user == null) {
      context.go(AppRoutes.login);
    } else if (user.isAdmin) {
      context.go(AppRoutes.admin);
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy800,
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (context, t, child) => Opacity(
            opacity: t.clamp(0, 1),
            child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandLogo(size: 104),
              const SizedBox(height: 28),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                AppConstants.appTagline,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 44),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(AppColors.safetyOrange),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
