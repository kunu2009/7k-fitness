import 'dart:async';
import 'package:flutter/material.dart';

/// Notification types for the app
enum NotificationType {
  workoutReminder,
  goalAchieved,
  streakReminder,
  waterReminder,
  mealReminder,
  weeklyReport,
  challengeUpdate,
  friendActivity,
  achievement,
}

/// Scheduled notification model
class ScheduledNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final bool isRepeating;
  final Duration? repeatInterval;
  final Map<String, dynamic>? payload;

  ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.isRepeating = false,
    this.repeatInterval,
    this.payload,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.index,
    'scheduledTime': scheduledTime.toIso8601String(),
    'isRepeating': isRepeating,
    'repeatInterval': repeatInterval?.inMinutes,
    'payload': payload,
  };

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values[json['type']],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isRepeating: json['isRepeating'] ?? false,
      repeatInterval: json['repeatInterval'] != null
          ? Duration(minutes: json['repeatInterval'])
          : null,
      payload: json['payload'],
    );
  }
}

/// Notification settings model
class NotificationSettings {
  final bool enabled;
  final bool workoutReminders;
  final bool mealReminders;
  final bool waterReminders;
  final bool achievementAlerts;
  final bool socialUpdates;
  final bool weeklyReports;
  final TimeOfDay morningReminderTime;
  final TimeOfDay eveningReminderTime;
  final List<int> workoutDays; // 1 = Monday, 7 = Sunday

  NotificationSettings({
    this.enabled = true,
    this.workoutReminders = true,
    this.mealReminders = true,
    this.waterReminders = true,
    this.achievementAlerts = true,
    this.socialUpdates = true,
    this.weeklyReports = true,
    this.morningReminderTime = const TimeOfDay(hour: 8, minute: 0),
    this.eveningReminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.workoutDays = const [1, 2, 3, 4, 5], // Weekdays by default
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? workoutReminders,
    bool? mealReminders,
    bool? waterReminders,
    bool? achievementAlerts,
    bool? socialUpdates,
    bool? weeklyReports,
    TimeOfDay? morningReminderTime,
    TimeOfDay? eveningReminderTime,
    List<int>? workoutDays,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      mealReminders: mealReminders ?? this.mealReminders,
      waterReminders: waterReminders ?? this.waterReminders,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      socialUpdates: socialUpdates ?? this.socialUpdates,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      morningReminderTime: morningReminderTime ?? this.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? this.eveningReminderTime,
      workoutDays: workoutDays ?? this.workoutDays,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'workoutReminders': workoutReminders,
    'mealReminders': mealReminders,
    'waterReminders': waterReminders,
    'achievementAlerts': achievementAlerts,
    'socialUpdates': socialUpdates,
    'weeklyReports': weeklyReports,
    'morningReminderTime':
        '${morningReminderTime.hour}:${morningReminderTime.minute}',
    'eveningReminderTime':
        '${eveningReminderTime.hour}:${eveningReminderTime.minute}',
    'workoutDays': workoutDays,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final morningParts = (json['morningReminderTime'] as String).split(':');
    final eveningParts = (json['eveningReminderTime'] as String).split(':');

    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      workoutReminders: json['workoutReminders'] ?? true,
      mealReminders: json['mealReminders'] ?? true,
      waterReminders: json['waterReminders'] ?? true,
      achievementAlerts: json['achievementAlerts'] ?? true,
      socialUpdates: json['socialUpdates'] ?? true,
      weeklyReports: json['weeklyReports'] ?? true,
      morningReminderTime: TimeOfDay(
        hour: int.parse(morningParts[0]),
        minute: int.parse(morningParts[1]),
      ),
      eveningReminderTime: TimeOfDay(
        hour: int.parse(eveningParts[0]),
        minute: int.parse(eveningParts[1]),
      ),
      workoutDays: List<int>.from(json['workoutDays'] ?? [1, 2, 3, 4, 5]),
    );
  }
}

/// Notification Service - handles all app notifications
/// Note: This is a mock implementation. For production, integrate with
/// flutter_local_notifications package.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<ScheduledNotification> _scheduledNotifications = [];
  NotificationSettings _settings = NotificationSettings();
  final StreamController<ScheduledNotification> _notificationStream =
      StreamController<ScheduledNotification>.broadcast();

  Stream<ScheduledNotification> get notificationStream =>
      _notificationStream.stream;
  NotificationSettings get settings => _settings;
  List<ScheduledNotification> get scheduledNotifications =>
      List.unmodifiable(_scheduledNotifications);

  /// Initialize the notification service
  Future<void> initialize() async {
    // In production, initialize flutter_local_notifications here
    // await _initializeLocalNotifications();
    _startNotificationChecker();
  }

  /// Update notification settings
  void updateSettings(NotificationSettings newSettings) {
    _settings = newSettings;
    if (!_settings.enabled) {
      cancelAllNotifications();
    }
  }

  /// Schedule a notification
  Future<void> scheduleNotification(ScheduledNotification notification) async {
    if (!_settings.enabled) return;

    _scheduledNotifications.add(notification);
    // In production, schedule with flutter_local_notifications
  }

  /// Schedule a workout reminder
  Future<void> scheduleWorkoutReminder({
    required TimeOfDay time,
    required List<int> days,
    String? customMessage,
  }) async {
    if (!_settings.workoutReminders) return;

    for (final day in days) {
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Find the next occurrence of this day
      while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      await scheduleNotification(
        ScheduledNotification(
          id: 'workout_reminder_$day',
          title: '💪 Time to Workout!',
          body:
              customMessage ??
              'Your scheduled workout is waiting. Let\'s crush it!',
          type: NotificationType.workoutReminder,
          scheduledTime: scheduledDate,
          isRepeating: true,
          repeatInterval: const Duration(days: 7),
        ),
      );
    }
  }

  /// Schedule water reminders throughout the day
  Future<void> scheduleWaterReminders({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required Duration interval,
  }) async {
    if (!_settings.waterReminders) return;

    final now = DateTime.now();
    var currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    int reminderCount = 0;
    while (currentTime.isBefore(endDateTime)) {
      if (currentTime.isAfter(now)) {
        await scheduleNotification(
          ScheduledNotification(
            id: 'water_reminder_$reminderCount',
            title: '💧 Stay Hydrated!',
            body: _getWaterReminderMessage(reminderCount),
            type: NotificationType.waterReminder,
            scheduledTime: currentTime,
            isRepeating: true,
            repeatInterval: const Duration(days: 1),
          ),
        );
      }
      currentTime = currentTime.add(interval);
      reminderCount++;
    }
  }

  /// Schedule meal reminders
  Future<void> scheduleMealReminders({
    TimeOfDay? breakfast,
    TimeOfDay? lunch,
    TimeOfDay? dinner,
  }) async {
    if (!_settings.mealReminders) return;

    final meals = [
      if (breakfast != null) ('breakfast', breakfast, '🍳 Breakfast Time!'),
      if (lunch != null) ('lunch', lunch, '🥗 Lunch Time!'),
      if (dinner != null) ('dinner', dinner, '🍽️ Dinner Time!'),
    ];

    final now = DateTime.now();
    for (final meal in meals) {
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        meal.$2.hour,
        meal.$2.minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await scheduleNotification(
        ScheduledNotification(
          id: 'meal_reminder_${meal.$1}',
          title: meal.$3,
          body: 'Don\'t forget to log your ${meal.$1}!',
          type: NotificationType.mealReminder,
          scheduledTime: scheduledTime,
          isRepeating: true,
          repeatInterval: const Duration(days: 1),
        ),
      );
    }
  }

  /// Send an immediate notification (for achievements, etc.)
  Future<void> showNotification({
    required String title,
    required String body,
    required NotificationType type,
    Map<String, dynamic>? payload,
  }) async {
    if (!_settings.enabled) return;

    // Check if this type is enabled
    if (!_isTypeEnabled(type)) return;

    final notification = ScheduledNotification(
      id: 'immediate_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      scheduledTime: DateTime.now(),
      payload: payload,
    );

    _notificationStream.add(notification);

    // In production, show with flutter_local_notifications
  }

  /// Show achievement unlocked notification
  Future<void> showAchievementNotification({
    required String achievementName,
    required String description,
    int? xpEarned,
  }) async {
    await showNotification(
      title: '🏆 Achievement Unlocked!',
      body:
          '$achievementName\n$description${xpEarned != null ? '\n+$xpEarned XP' : ''}',
      type: NotificationType.achievement,
      payload: {'achievement': achievementName, 'xp': xpEarned},
    );
  }

  /// Show goal achieved notification
  Future<void> showGoalAchievedNotification({
    required String goalName,
    required String details,
  }) async {
    await showNotification(
      title: '🎯 Goal Achieved!',
      body: '$goalName\n$details',
      type: NotificationType.goalAchieved,
      payload: {'goal': goalName},
    );
  }

  /// Show streak reminder
  Future<void> showStreakReminder({required int currentStreak}) async {
    await showNotification(
      title: '🔥 Don\'t Break Your Streak!',
      body: 'You\'re on a $currentStreak day streak. Keep it going!',
      type: NotificationType.streakReminder,
      payload: {'streak': currentStreak},
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(String id) async {
    _scheduledNotifications.removeWhere((n) => n.id == id);
    // In production, cancel with flutter_local_notifications
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    _scheduledNotifications.clear();
    // In production, cancel all with flutter_local_notifications
  }

  /// Cancel notifications by type
  Future<void> cancelNotificationsByType(NotificationType type) async {
    _scheduledNotifications.removeWhere((n) => n.type == type);
  }

  bool _isTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
        return _settings.workoutReminders;
      case NotificationType.mealReminder:
        return _settings.mealReminders;
      case NotificationType.waterReminder:
        return _settings.waterReminders;
      case NotificationType.achievement:
      case NotificationType.goalAchieved:
        return _settings.achievementAlerts;
      case NotificationType.friendActivity:
      case NotificationType.challengeUpdate:
        return _settings.socialUpdates;
      case NotificationType.weeklyReport:
        return _settings.weeklyReports;
      case NotificationType.streakReminder:
        return _settings.workoutReminders;
    }
  }

  String _getWaterReminderMessage(int reminderNumber) {
    final messages = [
      'Time for a glass of water! 💧',
      'Stay hydrated! Your body will thank you.',
      'Water break! Keep up the good work.',
      'Hydration check! Have you had enough water?',
      'Remember to drink water! 💪',
      'Your daily water goal awaits!',
      'Sip, sip! Time for more water.',
      'Keep the hydration going! 🌊',
    ];
    return messages[reminderNumber % messages.length];
  }

  void _startNotificationChecker() {
    // Periodic check for scheduled notifications (mock implementation)
    Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final dueNotifications = _scheduledNotifications
          .where(
            (n) =>
                n.scheduledTime.isBefore(now) ||
                n.scheduledTime.isAtSameMomentAs(now),
          )
          .toList();

      for (final notification in dueNotifications) {
        _notificationStream.add(notification);

        if (notification.isRepeating && notification.repeatInterval != null) {
          // Reschedule repeating notifications
          _scheduledNotifications.remove(notification);
          _scheduledNotifications.add(
            ScheduledNotification(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              type: notification.type,
              scheduledTime: notification.scheduledTime.add(
                notification.repeatInterval!,
              ),
              isRepeating: true,
              repeatInterval: notification.repeatInterval,
              payload: notification.payload,
            ),
          );
        } else {
          _scheduledNotifications.remove(notification);
        }
      }
    });
  }

  void dispose() {
    _notificationStream.close();
  }
}
