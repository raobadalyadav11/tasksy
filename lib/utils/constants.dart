class AppConstants {
  // App Info
  static const String appName = 'Tasksy';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Professional Todo & Habit Tracker';

  // Colors
  static const int primaryColor = 0xFF4A90E2;
  static const int accentColor = 0xFFF5A623;
  static const int backgroundColor = 0xFFF8F9FA;
  static const int darkBackgroundColor = 0xFF2C2F33;

  // Storage Keys
  static const String tasksKey = 'tasks';
  static const String habitsKey = 'habits';
  static const String settingsKey = 'settings';
  static const String firstTimeKey = 'first_time';

  // Notification IDs
  static const int dailyReminderId = 999999;
  static const int taskReminderOffset = 0;
  static const int habitReminderOffset = 10000;
  static const int recurringTaskOffset = 20000;

  // Ad Settings
  static const int interstitialAdFrequency = 3; // Show after every 3 completed tasks
  static const int rewardedAdStreakMilestone = 7; // Show for 7-day streaks

  // Default Settings
  static const Map<String, dynamic> defaultSettings = {
    'notifications': true,
    'sound': true,
    'vibration': true,
    'darkMode': false,
    'autoBackup': false,
    'reminderTime': '09:00',
    'taskReminders': true,
    'habitReminders': true,
    'overdueReminders': true,
    'streakCelebrations': true,
  };

  // Categories
  static const List<String> taskCategories = [
    'Personal',
    'Work', 
    'Health',
    'Shopping',
    'Study',
    'Finance'
  ];

  // Priorities
  static const List<String> taskPriorities = ['Low', 'Medium', 'High'];

  // Habit Frequencies
  static const List<String> habitFrequencies = ['Daily', 'Weekly', 'Monthly'];

  // Habit Colors
  static const Map<String, int> habitColors = {
    'blue': 0xFF2196F3,
    'green': 0xFF4CAF50,
    'orange': 0xFFFF9800,
    'purple': 0xFF9C27B0,
    'red': 0xFFF44336,
  };

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Notification Durations
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration flushbarDuration = Duration(seconds: 3);
  static const Duration overlayDuration = Duration(seconds: 4);
}