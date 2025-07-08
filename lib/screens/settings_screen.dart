import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/ad_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
        'darkMode': loadedSettings['darkMode'] ?? false,
        'autoBackup': loadedSettings['autoBackup'] ?? false,
        'reminderTime': loadedSettings['reminderTime'] ?? '09:00',
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
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data'),
        content: const Text(
          'This will permanently delete all your tasks, habits, and settings. This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data has been reset')),
      );
    }
  }

  Future<void> _showThemeSelection() async {
    AdService.showRewardedAd(
      onUserEarnedReward: (ad, reward) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium theme unlocked!')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications Section
          _buildSectionHeader('Notifications'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive reminders for tasks and habits'),
                  value: settings['notifications'] ?? true,
                  onChanged: (value) => _updateSetting('notifications', value),
                  secondary: const Icon(Icons.notifications),
                ),
                const Divider(height: 1),
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
                  title: const Text('Daily Reminder Time'),
                  subtitle: Text('Remind me at ${settings['reminderTime']}'),
                  leading: const Icon(Icons.schedule),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _selectReminderTime(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: settings['darkMode'] ?? false,
                  onChanged: (value) => _updateSetting('darkMode', value),
                  secondary: const Icon(Icons.dark_mode),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Themes'),
                  subtitle: const Text('Customize app appearance'),
                  leading: const Icon(Icons.palette),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showThemeSelection,
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Stickers & Icons'),
                  subtitle: const Text('Unlock premium content'),
                  leading: const Icon(Icons.star),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Watch Ad',
                          style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                  onTap: _showThemeSelection,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data & Backup Section
          _buildSectionHeader('Data & Backup'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically backup data locally'),
                  value: settings['autoBackup'] ?? false,
                  onChanged: (value) => _updateSetting('autoBackup', value),
                  secondary: const Icon(Icons.backup),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Export Data'),
                  subtitle: const Text('Export tasks and habits'),
                  leading: const Icon(Icons.download),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showExportDialog(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Import Data'),
                  subtitle: const Text('Import from backup file'),
                  leading: const Icon(Icons.upload),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showImportDialog(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                  leading: Icon(Icons.info),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacy Policy'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showPrivacyPolicy(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Terms of Service'),
                  leading: const Icon(Icons.description),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _showTermsOfService(),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Rate App'),
                  leading: const Icon(Icons.star_rate),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _rateApp(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          Card(
            color: Colors.red.withOpacity(0.1),
            child: ListTile(
              title: const Text('Reset All Data', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: const Text('Permanently delete all tasks, habits, and settings'),
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
              onTap: _showResetDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A90E2),
        ),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _updateSetting('reminderTime', timeString);
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('Export functionality will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('Import functionality will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Tasksy Privacy Policy\n\n'
            'We respect your privacy and are committed to protecting your personal data. '
            'This app stores all data locally on your device and does not collect or share '
            'personal information with third parties.\n\n'
            'Data Collection:\n'
            '• Tasks and habits are stored locally\n'
            '• No personal data is transmitted\n'
            '• Analytics are anonymous\n\n'
            'For questions, contact us at support@tasksy.app',
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

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Tasksy Terms of Service\n\n'
            'By using this app, you agree to these terms:\n\n'
            '1. The app is provided "as is" without warranties\n'
            '2. You are responsible for your data backup\n'
            '3. We may update the app and terms periodically\n'
            '4. You must not misuse the app or violate laws\n\n'
            'For full terms, visit our website or contact support@tasksy.app',
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

  void _rateApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Tasksy'),
        content: const Text('Thank you for using Tasksy! Please rate us on the app store to help others discover our app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
    );
  }
}