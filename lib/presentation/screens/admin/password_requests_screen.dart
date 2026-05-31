import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';

class PasswordRequestsScreen extends ConsumerWidget {
  const PasswordRequestsScreen({super.key});

  static final _fmt = DateFormat('d MMM yyyy HH:mm', 'id');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(passwordResetRequestsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 64, color: AppColors.success),
                  const SizedBox(height: 12),
                  Text('Tidak ada permintaan pending',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final req = requests[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.userName,
                                    style: theme.textTheme.titleSmall),
                                Text(req.email,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textMuted)),
                                if (req.nik.isNotEmpty)
                                  Text('NIK: ${req.nik}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: const Text('Pending',
                                style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diminta: ${_fmt.format(req.requestedAt)}',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _sendResetEmail(context, ref, req),
                              icon: const Icon(Icons.email_outlined, size: 16),
                              label: const Text('Kirim Email Reset'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.safetyOrange),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _markDone(req.userId),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Tandai Selesai'),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _sendResetEmail(
    BuildContext context,
    WidgetRef ref,
    PasswordResetRequest req,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final err = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(req.email);
    if (err == null) {
      await _markDone(req.userId);
      messenger.showSnackBar(
        SnackBar(content: Text('Email reset terkirim ke ${req.email}')),
      );
    } else {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $err')));
    }
  }

  Future<void> _markDone(String userId) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.passwordResetRequestsCollection)
        .doc(userId)
        .update({'status': 'processed'});
  }
}
