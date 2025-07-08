import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  Map<String, dynamic> settings = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final loadedSettings = await StorageService.getSettings();
    setState(() {
      settings = {
        'notifications': loadedSettings['notifications'] ?? true,
        'sound': loadedSettings['sound'] ?? true,
        'vibration': loadedSettings['vibration'] ?? true,
        'reminderTime': loadedSettings['reminderTime'] ?? '09:00',
        'taskReminders': loadedSettings['taskReminders'] ?? true,
        'habitReminders': loadedSettings['habitReminders'] ?? true,
        'overdueReminders': loadedSettings['overdueReminders'] ?? true,
        'streakCelebrations': loadedSettings['streakCelebrations'] ?? true,
        ...loadedSettings,
      };
      isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    setState(() {
      settings[key] = value;
    });
    await StorageService.saveSettings(settings);
    
    if (key == 'notifications' || key == 'reminderTime') {
      if (value == true || key == 'reminderTime') {
        await NotificationService.scheduleDailyReminder();
      } else {
        await NotificationService.cancelAllNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Master Toggle
          Card(
            child: SwitchListTile(
              title: const Text('Enable All Notifications'),
              subtitle: const Text('Master switch for all reminders'),
              value: settings['notifications'] ?? true,
              onChanged: (value) => _updateSetting('notifications', value),
              secondary: const Icon(Icons.notifications),
            ),
          ),

          const SizedBox(height: 16),

          // Notification Types
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Notification Types',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Task Reminders'),
                  subtitle: const Text('Notifications for task due dates'),
                  value: settings['taskReminders'] ?? true,
                  onChanged: (value) => _updateSetting('taskReminders', value),
                  secondary: const Icon(Icons.task_alt),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Habit Reminders'),
                  subtitle: const Text('Daily habit completion reminders'),
                  value: settings['habitReminders'] ?? true,
                  onChanged: (value) => _updateSetting('habitReminders', value),
                  secondary: const Icon(Icons.track_changes),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Overdue Alerts'),
                  subtitle: const Text('Notifications for overdue tasks'),
                  value: settings['overdueReminders'] ?? true,
                  onChanged: (value) => _updateSetting('overdueReminders', value),
                  secondary: const Icon(Icons.warning),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Streak Celebrations'),
                  subtitle: const Text('Celebrate habit milestones'),
                  value: settings['streakCelebrations'] ?? true,
                  onChanged: (value) => _updateSetting('streakCelebrations', value),
                  secondary: const Icon(Icons.celebration),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sound & Vibration
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sound & Vibration',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Sound'),
                  subtitle: const Text('Play sound for notifications'),
                  value: settings['sound'] ?? true,
                  onChanged: (value) => _updateSetting('sound', value),
                  secondary: const Icon(Icons.volume_up),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Vibration'),
                  subtitle: const Text('Vibrate for notifications'),
                  value: settings['vibration'] ?? true,
                  onChanged: (value) => _updateSetting('vibration', value),
                  secondary: const Icon(Icons.vibration),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Test Sound'),
                  subtitle: const Text('Test notification sound'),
                  leading: const Icon(Icons.play_arrow),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await NotificationService.showInstantNotification(
                      'Sound Test',
                      'Testing notification sound and vibration',
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Daily Reminder Time
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Daily Reminder',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: const Text('Reminder Time'),
                  subtitle: Text('Daily check-in at ${settings['reminderTime']}'),
                  leading: const Icon(Icons.schedule),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectReminderTime(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Send Test Reminder'),
                  subtitle: const Text('Test daily reminder notification'),
                  leading: const Icon(Icons.send),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await NotificationService.showInstantNotification(
                      'Daily Productivity Check',
                      '🌟 Ready to tackle your tasks and habits today?',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test reminder sent!')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  title: const Text('View Pending Notifications'),
                  subtitle: const Text('See all scheduled reminders'),
                  leading: const Icon(Icons.list),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showPendingNotifications(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Cancel All Notifications'),
                  subtitle: const Text('Clear all pending reminders'),
                  leading: const Icon(Icons.clear_all),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showCancelAllDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final currentTimeStr = settings['reminderTime'] ?? '09:00';
    final timeParts = currentTimeStr.split(':');
    final currentTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    
    final time = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateSetting('reminderTime', timeString);
    }
  }

  Future<void> _showPendingNotifications() async {
    final pending = await NotificationService.getPendingNotifications();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pending Notifications'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: pending.isEmpty
              ? const Center(child: Text('No pending notifications'))
              : ListView.builder(
                  itemCount: pending.length,
                  itemBuilder: (context, index) {
                    final notification = pending[index];
                    return Card(
                      child: ListTile(
                        title: Text(notification.title ?? 'No title'),
                        subtitle: Text(notification.body ?? 'No body'),
                        leading: const Icon(Icons.notifications),
                        trailing: Text('ID: ${notification.id}'),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Notifications'),
        content: const Text('This will cancel all pending reminders. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await NotificationService.cancelAllNotifications();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All notifications cancelled')),
      );
    }
  }
}