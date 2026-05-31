import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Top-level handler required by FCM for background messages.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized at this point.
  debugPrint('FCM background: ${message.messageId}');
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

  Future<void> init() async {
    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS / Android 13+).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Android local notification channel.
    if (Platform.isAndroid) {
      final plugin = _localNotifs.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.createNotificationChannel(_androidChannel);
    }

    // Init local notifications.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifs.initialize(initSettings);

    // Foreground FCM — show local notification.
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // On iOS, APNS token may not be ready immediately at cold start.
    // Retry once after a short delay instead of crashing the app.
    try {
      final token = await _fcm.getToken();
      debugPrint('FCM token: $token');
    } catch (e) {
      debugPrint('FCM getToken skipped at startup (APNS not ready yet): $e');
      // Token will be fetched later when APNS handshake completes.
      _fcm.onTokenRefresh.first.then((token) {
        debugPrint('FCM token (deferred): $token');
      });
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

  /// Show a local notification immediately (e.g., after successful clock-in).
  Future<void> showClockInSuccess({required String time}) async {
    await _localNotifs.show(
      1,
      'Clock In Berhasil',
      'Anda berhasil absen masuk pukul $time',
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
  }

  /// Show a local notification for GPS/face detection failure.
  Future<void> showAttendanceFailure({required String reason}) async {
    await _localNotifs.show(
      2,
      'Absensi Gagal',
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
  }

  /// Subscribe to topic for attendance reminders.
  Future<void> subscribeToReminders() async {
    await _fcm.subscribeToTopic('attendance_reminders');
  }

  Future<void> unsubscribeFromReminders() async {
    await _fcm.unsubscribeFromTopic('attendance_reminders');
  }
}
