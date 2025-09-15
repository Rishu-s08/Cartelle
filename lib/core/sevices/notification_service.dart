import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Call this once in main.dart
  Future<void> initialize() async {
    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied ||
        await Permission.notification.isPermanentlyDenied) {
      final status = await Permission.notification.request();
      debugPrint('Notification permission status: $status');
    }
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    tz.initializeTimeZones();
    String currentTimezone = await FlutterTimezone.getLocalTimezone();
    if (currentTimezone == 'Asia/Calcutta') {
      currentTimezone = 'Asia/Kolkata';
    }
    tz.setLocalLocation(tz.getLocation(currentTimezone));

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Notification tapped: [34m${details.payload}[0m');
      },
    );
  }

  /// For debugging: show an immediate notification
  static Future<void> testImmediateNotification() async {
    await showNotification(
      title: 'Test Immediate',
      body: 'This is a test notification.',
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'geofence_channel_id',
          'Geofence Alerts',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
          color: Color(0xFF8D6748),
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(0, title, body, platformDetails);
  }

  static Future<void> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      print("Cannot schedule in the past: $scheduledDate");
      return;
    }
    print('Scheduling reminder for $scheduledDate');

    // tz.initializeTimeZones();
    // tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    final now = tz.TZDateTime.now(tz.local);

    final tzscheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      15,
      49,
    );
    print('Converted to TZDateTime: $tzscheduledDate');
    await _notificationsPlugin.zonedSchedule(
      id.hashCode,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Notification channel for reminders',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
          color: Color(0xFF8D6748),
        ),
      ),

      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle, // Use exact alarms for reminders
      matchDateTimeComponents: null,
    );
  }

  static Future<void> testNotification() async {
    final now = DateTime.now();
    final scheduled = now.add(const Duration(seconds: 30));
    print("⏰ Scheduling test notification for $scheduled");

    await _notificationsPlugin.zonedSchedule(
      1,
      "Test Reminder",
      "This is a test notification",
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Channel',
          channelDescription: 'For testing notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      matchDateTimeComponents: null,
    );
  }
}
