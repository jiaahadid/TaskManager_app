import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  /// Schedule a notification 1 day before the task due date at 8:00 AM
  static Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    // Reminder fires 1 day before at 8:00 AM
    final reminderDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 1,
      8,
      0,
    );

    // Don't schedule if reminder time is already in the past
    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('Reminder time already passed, skipping notification.');
      return;
    }

    final tzReminderDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _notifications.zonedSchedule(
      id,
      '📅 Task Due Tomorrow!',
      '"$taskTitle" is due tomorrow. Get it done! 💗',
      tzReminderDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder_channel',
          'Task Reminders',
          channelDescription: 'Reminds you 1 day before a task is due',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint('Notification scheduled for: $tzReminderDate');
  }

  /// Cancel a notification by task id (call when task is deleted or completed)
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    debugPrint('Notification $id cancelled');
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}