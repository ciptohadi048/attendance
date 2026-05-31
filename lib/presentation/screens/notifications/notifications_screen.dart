import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationHistoryItem> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await NotificationService.instance.getHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  Future<void> _clearHistory() async {
    await NotificationService.instance.clearHistory();
    if (mounted) {
      setState(() => _history = []);
    }
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
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Hapus semua',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hapus Notifikasi'),
                    content: const Text(
                        'Hapus semua riwayat notifikasi?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) _clearHistory();
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
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
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final item = _history[i];
                      final timeStr =
                          DateFormat('dd MMM yyyy, HH:mm').format(item.timestamp);
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            _iconForTitle(item.title),
                            color: _colorForTitle(item.title),
                          ),
                          title: Text(item.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.body),
                              const SizedBox(height: 4),
                              Text(
                                timeStr,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _iconForTitle(String title) {
    if (title.contains('Berhasil')) return Icons.check_circle_rounded;
    if (title.contains('Gagal')) return Icons.error_rounded;
    if (title.contains('Pengingat')) return Icons.alarm_rounded;
    return Icons.notifications_rounded;
  }

  Color _colorForTitle(String title) {
    if (title.contains('Berhasil')) return Colors.green;
    if (title.contains('Gagal')) return Colors.red;
    if (title.contains('Pengingat')) return AppColors.safetyOrange;
    return AppColors.safetyOrange;
  }
}
