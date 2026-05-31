import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/l10n_extension.dart';
import '../../../domain/entities/app_user.dart';
import '../../providers/auth_providers.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../router/app_routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncUser = ref.watch(authStateProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: l10n.editProfile,
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: asyncUser.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return const SizedBox.shrink();
          return _ProfileBody(user: user, ref: ref);
        },
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user, required this.ref});
  final AppUser user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Identity card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _Avatar(user: user, radius: 48),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.safetyOrange,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.navy700, width: 2),
                      ),
                      child: const Icon(Icons.badge_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(user.name,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                _RoleBadge(role: user.role),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _IdentityRow(
                  icon: Icons.numbers_rounded,
                  label: 'NIK',
                  value: user.nik.isEmpty ? '-' : user.nik,
                ),
                const SizedBox(height: 12),
                _IdentityRow(
                  icon: Icons.email_outlined,
                  label: l10n.email,
                  value: user.email,
                ),
                if (user.department != null) ...[
                  const SizedBox(height: 12),
                  _IdentityRow(
                    icon: Icons.business_rounded,
                    label: l10n.department,
                    value: user.department!,
                  ),
                ],
                if (user.position != null) ...[
                  const SizedBox(height: 12),
                  _IdentityRow(
                    icon: Icons.work_outline_rounded,
                    label: l10n.position,
                    value: user.position!,
                  ),
                ],
                if (user.phoneNumber != null) ...[
                  const SizedBox(height: 12),
                  _IdentityRow(
                    icon: Icons.phone_outlined,
                    label: l10n.phone,
                    value: user.phoneNumber!,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Settings
        Card(
          child: Column(
            children: [
              // Language switcher
              ListTile(
                leading: const Icon(Icons.language_rounded,
                    color: AppColors.safetyOrange),
                title: Text(l10n.language),
                trailing: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'id', label: Text(l10n.indonesian)),
                    ButtonSegment(value: 'en', label: Text(l10n.english)),
                  ],
                  selected: {currentLocale.languageCode},
                  onSelectionChanged: (selected) {
                    ref.read(localeProvider.notifier).setLocale(selected.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Theme toggle
              ListTile(
                leading: Icon(
                  ref.watch(themeModeProvider) == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: AppColors.safetyOrange,
                ),
                title: Text(ref.watch(themeModeProvider) == ThemeMode.dark
                    ? l10n.darkMode
                    : l10n.lightMode),
                trailing: Switch(
                  value: ref.watch(themeModeProvider) == ThemeMode.dark,
                  onChanged: (_) =>
                      ref.read(themeModeProvider.notifier).toggle(),
                  activeColor: AppColors.safetyOrange,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Actions
        Card(
          child: Column(
            children: [
              _ActionTile(
                icon: Icons.lock_reset_rounded,
                label: l10n.changePassword,
                onTap: () => context.push(AppRoutes.changePassword),
              ),
              const Divider(height: 1, indent: 56),
              _ActionTile(
                icon: Icons.logout_rounded,
                label: l10n.logout,
                color: AppColors.danger,
                onTap: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.logout),
                      content: Text(l10n.logoutConfirm),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel)),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l10n.logout,
                                style:
                                    const TextStyle(color: AppColors.danger))),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref
                        .read(authControllerProvider.notifier)
                        .signOut();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, required this.radius});
  final AppUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (user.photoUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(user.photoUrl!),
        backgroundColor: AppColors.navy600,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.safetyOrange.withValues(alpha: 0.2),
      child: Text(
        user.initials,
        style: TextStyle(
          color: AppColors.safetyOrange,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAdmin = role == UserRole.admin;
    final color = isAdmin ? AppColors.safetyOrange : AppColors.info;
    final label = isAdmin ? l10n.admin : l10n.employee;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _IdentityRow extends StatelessWidget {
  const _IdentityRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.safetyOrange),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted)),
            Text(value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
