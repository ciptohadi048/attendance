import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<RemoteMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Collect foreground messages while this screen is open.
    FirebaseMessaging.onMessage.listen((msg) {
      if (mounted) setState(() => _messages.insert(0, msg));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: _messages.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none_rounded,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Belum ada notifikasi',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final msg = _messages[i];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_rounded,
                        color: AppColors.safetyOrange),
                    title: Text(msg.notification?.title ?? 'Notifikasi'),
                    subtitle: Text(msg.notification?.body ?? ''),
                  ),
                );
              },
            ),
    );
  }
}
