import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Top-level handler required by FCM for background messages.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized at this point.
  debugPrint('FCM background: ${message.messageId}');
  // Persist notification for history.
  await NotificationService.instance._persistNotification(
    title: message.notification?.title ?? 'Notifikasi',
    body: message.notification?.body ?? '',
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifs = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'factory_attendance_channel',
    'Factory Attendance',
    description: 'Notifikasi absensi karyawan',
    importance: Importance.high,
  );

  static const _reminderChannelId = 'attendance_reminder_channel';
  static const _reminderChannel = AndroidNotificationChannel(
    _reminderChannelId,
    'Pengingat Absensi',
    description: 'Pengingat harian untuk clock-in',
    importance: Importance.high,
  );

  /// Key for storing notification history in SharedPreferences.
  static const _historyKey = 'notification_history';

  /// Key for reminder enabled state.
  static const _reminderEnabledKey = 'reminder_enabled';

  Future<void> init() async {
    // Initialize timezone data.
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS / Android 13+).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android local notification channels.
    if (Platform.isAndroid) {
      final plugin = _localNotifs.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.createNotificationChannel(_androidChannel);
      await plugin?.createNotificationChannel(_reminderChannel);
    }

    // Init local notifications.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifs.initialize(initSettings);

    // Foreground FCM — show local notification and persist.
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
      _persistNotification(
        title: message.notification?.title ?? 'Notifikasi',
        body: message.notification?.body ?? '',
      );
    });

    // On iOS, APNS token may not be ready immediately at cold start.
    try {
      final token = await _fcm.getToken();
      debugPrint('FCM token: $token');
    } catch (e) {
      debugPrint('FCM getToken skipped at startup (APNS not ready yet): $e');
      _fcm.onTokenRefresh.first.then((token) {
        debugPrint('FCM token (deferred): $token');
      });
    }

    // Subscribe to reminders topic by default.
    await subscribeToReminders();

    // Schedule daily reminder if enabled (default: enabled).
    final prefs = await SharedPreferences.getInstance();
    final reminderEnabled = prefs.getBool(_reminderEnabledKey) ?? true;
    if (reminderEnabled) {
      await scheduleDailyReminder();
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifs.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Scheduled Daily Reminder
  // ---------------------------------------------------------------------------

  /// Schedule a daily reminder at 07:50 WIB to remind user to clock in.
  Future<void> scheduleDailyReminder({int hour = 7, int minute = 50}) async {
    await _localNotifs.zonedSchedule(
      100, // fixed ID for daily reminder
      'Pengingat Absensi',
      'Jangan lupa clock-in hari ini! Waktu absen masuk pukul 08:00.',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _reminderChannel.id,
          _reminderChannel.name,
          channelDescription: _reminderChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Persist preference.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, true);

    debugPrint('Daily reminder scheduled at $hour:$minute WIB');
  }

  /// Cancel the daily reminder.
  Future<void> cancelDailyReminder() async {
    await _localNotifs.cancel(100);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderEnabledKey, false);
    debugPrint('Daily reminder cancelled');
  }

  /// Check if daily reminder is enabled.
  Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderEnabledKey) ?? true;
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  // ---------------------------------------------------------------------------
  // Immediate Notifications (clock-in/out feedback)
  // ---------------------------------------------------------------------------

  /// Show a local notification immediately (e.g., after successful clock-in).
  Future<void> showClockInSuccess({required String time}) async {
    const title = 'Clock In Berhasil';
    final body = 'Anda berhasil absen masuk pukul $time';
    await _localNotifs.show(
      1,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
    await _persistNotification(title: title, body: body);
  }

  /// Show a local notification for clock-out success.
  Future<void> showClockOutSuccess({required String time}) async {
    const title = 'Clock Out Berhasil';
    final body = 'Anda berhasil absen pulang pukul $time';
    await _localNotifs.show(
      3,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
    await _persistNotification(title: title, body: body);
  }

  /// Show a local notification for GPS/face detection failure.
  Future<void> showAttendanceFailure({required String reason}) async {
    const title = 'Absensi Gagal';
    await _localNotifs.show(
      2,
      title,
      reason,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
    await _persistNotification(title: title, body: reason);
  }

  // ---------------------------------------------------------------------------
  // FCM Topic Subscription
  // ---------------------------------------------------------------------------

  /// Subscribe to topic for attendance reminders.
  Future<void> subscribeToReminders() async {
    await _fcm.subscribeToTopic('attendance_reminders');
  }

  Future<void> unsubscribeFromReminders() async {
    await _fcm.unsubscribeFromTopic('attendance_reminders');
  }

  // ---------------------------------------------------------------------------
  // Notification History (persisted via SharedPreferences)
  // ---------------------------------------------------------------------------

  /// Persist a notification to local storage for history display.
  Future<void> _persistNotification({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    final timestamp = DateTime.now().toIso8601String();
    // Format: timestamp|title|body
    history.insert(0, '$timestamp|$title|$body');
    // Keep max 100 notifications.
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await prefs.setStringList(_historyKey, history);
  }

  /// Get notification history.
  Future<List<NotificationHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_historyKey) ?? [];
    return history.map((entry) {
      final parts = entry.split('|');
      if (parts.length >= 3) {
        return NotificationHistoryItem(
          timestamp: DateTime.tryParse(parts[0]) ?? DateTime.now(),
          title: parts[1],
          body: parts.sublist(2).join('|'), // body may contain '|'
        );
      }
      return NotificationHistoryItem(
        timestamp: DateTime.now(),
        title: 'Notifikasi',
        body: entry,
      );
    }).toList();
  }

  /// Clear notification history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}

/// Model for notification history items.
class NotificationHistoryItem {
  final DateTime timestamp;
  final String title;
  final String body;

  NotificationHistoryItem({
    required this.timestamp,
    required this.title,
    required this.body,
  });
}
