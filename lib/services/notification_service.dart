import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';
import '../models/habit.dart';
import 'storage_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      await _playNotificationSound();
    }
  }

  static Future<void> _playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      // Fallback to system sound if custom sound fails
    }
  }

  static Future<void> scheduleTaskReminder(Task task) async {
    if (task.dueDate == null) return;

    final settings = await StorageService.getSettings();
    if (!(settings['notifications'] ?? true)) return;

    final scheduledDate = tz.TZDateTime.from(task.dueDate!, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (scheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      task.id.hashCode,
      'Task Reminder',
      '📋 ${task.title}',
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Reminders for your tasks',
          importance: Importance.high,
          priority: Priority.high,
          playSound: settings['sound'] ?? true,
          enableVibration: settings['vibration'] ?? true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'task_${task.id}',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleHabitReminder(
    Habit habit,
    TimeOfDay reminderTime,
  ) async {
    final settings = await StorageService.getSettings();
    if (!(settings['notifications'] ?? true)) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      habit.id.hashCode + 10000, // Offset to avoid conflicts with tasks
      'Habit Reminder',
      '🎯 Time for ${habit.name}!',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Daily reminders for your habits',
          importance: Importance.high,
          priority: Priority.high,
          playSound: settings['sound'] ?? true,
          enableVibration: settings['vibration'] ?? true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'habit_${habit.id}',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleDailyReminder() async {
    final settings = await StorageService.getSettings();
    if (!(settings['notifications'] ?? true)) return;

    final reminderTimeStr = settings['reminderTime'] ?? '09:00';
    final timeParts = reminderTimeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notifications.zonedSchedule(
      999999, // Unique ID for daily reminder
      'Daily Productivity Check',
      '🌟 Ready to tackle your tasks and habits today?',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          channelDescription: 'Daily motivation and check-ins',
          importance: Importance.high,
          priority: Priority.high,
          playSound: settings['sound'] ?? true,
          enableVibration: settings['vibration'] ?? true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'daily_reminder',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> showInstantNotification(String title, String body) async {
    final settings = await StorageService.getSettings();

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_notifications',
          'Instant Notifications',
          channelDescription: 'Immediate notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: settings['sound'] ?? true,
          enableVibration: settings['vibration'] ?? true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    if (settings['sound'] ?? true) {
      await _playNotificationSound();
    }
  }

  static Future<void> cancelTaskReminder(String taskId) async {
    await _notifications.cancel(taskId.hashCode);
  }

  static Future<void> cancelHabitReminder(String habitId) async {
    await _notifications.cancel(habitId.hashCode + 10000);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleRecurringTaskReminder(Task task) async {
    if (!task.isRecurring || task.dueDate == null) return;

    final settings = await StorageService.getSettings();
    if (!(settings['notifications'] ?? true)) return;

    // Schedule next occurrence based on recurrence type
    DateTime nextDate = task.dueDate!;

    switch (task.recurrenceType) {
      case 'daily':
        nextDate = nextDate.add(const Duration(days: 1));
        break;
      case 'weekly':
        nextDate = nextDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        break;
    }

    final tzScheduledDate = tz.TZDateTime.from(nextDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);

    if (tzScheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      task.id.hashCode + 20000, // Different offset for recurring
      'Recurring Task',
      '🔄 ${task.title} (${task.recurrenceType})',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'recurring_tasks',
          'Recurring Task Reminders',
          channelDescription: 'Reminders for recurring tasks',
          importance: Importance.high,
          priority: Priority.high,
          playSound: settings['sound'] ?? true,
          enableVibration: settings['vibration'] ?? true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'recurring_task_${task.id}',
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> scheduleOverdueReminder(Task task) async {
    if (task.isCompleted || task.dueDate == null) return;

    final now = DateTime.now();
    if (!task.dueDate!.isBefore(now)) return;

    await showInstantNotification(
      'Overdue Task',
      '⚠️ ${task.title} is overdue!',
    );
  }

  static Future<void> scheduleStreakCelebration(Habit habit) async {
    if (habit.streak > 0 && habit.streak % 7 == 0) {
      await showInstantNotification(
        'Streak Milestone! 🎉',
        '${habit.name}: ${habit.streak} day streak!',
      );
    }
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
