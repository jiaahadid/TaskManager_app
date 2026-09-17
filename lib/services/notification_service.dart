import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      tz_data.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
          InitializationSettings(android: androidSettings);

      await _notifications.initialize(settings);

      final android = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  /// Schedule a notification 1 day before the task due date at 8:00 AM
  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    try {
      // Reminder fires 1 day before at 8:00 AM
      final reminderDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        8,
        0,
      ).subtract(const Duration(days: 1));

      // Don't schedule if reminder time is already in the past
      if (reminderDate.isBefore(DateTime.now())) {
        debugPrint('Reminder time already passed, skipping notification.');
        return;
      }

      final tzReminderDate = tz.TZDateTime.from(reminderDate, tz.local);
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel',
          'Task Reminders',
          channelDescription: 'Reminds you 1 day before a task is due',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      );

      try {
        await _notifications.zonedSchedule(
          id,
          '📅 Task Due Tomorrow!',
          '"$taskTitle" is due tomorrow. Get it done! 💗',
          tzReminderDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('Exact alarm failed, using inexact schedule: $e');
        await _notifications.zonedSchedule(
          id,
          '📅 Task Due Tomorrow!',
          '"$taskTitle" is due tomorrow. Get it done! 💗',
          tzReminderDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      debugPrint('Notification scheduled for: $tzReminderDate');
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  /// Cancel a notification by task id (call when task is deleted or completed)
  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('Notification $id cancelled');
    } catch (e) {
      debugPrint('Failed to cancel notification $id: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Failed to cancel all notifications: $e');
    }
  }
}
