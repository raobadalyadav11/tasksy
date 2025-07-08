import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick Start Guide
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.play_arrow, color: Color(0xFF4A90E2)),
              title: const Text('Quick Start Guide'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStep(
                        '1',
                        'Tap the + button to create your first task',
                      ),
                      _buildStep(
                        '2',
                        'Set due dates and priorities for better organization',
                      ),
                      _buildStep(
                        '3',
                        'Create habits to build lasting routines',
                      ),
                      _buildStep('4', 'Check analytics to track your progress'),
                      _buildStep('5', 'Customize settings and notifications'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // FAQ Section
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.help, color: Color(0xFF4A90E2)),
              title: const Text('Frequently Asked Questions'),
              children: [
                _buildFAQItem(
                  'How do I create a recurring task?',
                  'When creating a task, toggle the "Recurring Task" option and select daily, weekly, or monthly frequency.',
                ),
                _buildFAQItem(
                  'Can I backup my data?',
                  'Yes! Go to Settings > Data & Backup to enable auto-backup or manually export your data.',
                ),
                _buildFAQItem(
                  'How do habit streaks work?',
                  'Complete your habit daily to build a streak. Missing a day will reset your streak to zero.',
                ),
                _buildFAQItem(
                  'Can I customize notification sounds?',
                  'Yes! Go to Settings > Reminder Settings to customize notification preferences including sounds.',
                ),
                _buildFAQItem(
                  'How do I delete completed tasks?',
                  'Swipe left on any task to delete it, or tap the task to view details and delete from there.',
                ),
              ],
            ),
          ),

          // Features Guide
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.star, color: Color(0xFF4A90E2)),
              title: const Text('Features Guide'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFeatureGuide(
                        'Tasks',
                        'Create, organize, and track your daily tasks with due dates, priorities, and categories.',
                      ),
                      _buildFeatureGuide(
                        'Habits',
                        'Build lasting habits with streak tracking and visual progress indicators.',
                      ),
                      _buildFeatureGuide(
                        'Analytics',
                        'View detailed statistics about your productivity and habit consistency.',
                      ),
                      _buildFeatureGuide(
                        'Reminders',
                        'Set custom notifications for tasks and daily habit reminders.',
                      ),
                      _buildFeatureGuide(
                        'Themes',
                        'Personalize your app with different color themes and customizations.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tips & Tricks
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.lightbulb, color: Color(0xFF4A90E2)),
              title: const Text('Tips & Tricks'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTip(
                        '💡',
                        'Use priority colors to quickly identify important tasks',
                      ),
                      _buildTip(
                        '🔄',
                        'Set recurring tasks for regular activities like weekly meetings',
                      ),
                      _buildTip(
                        '📊',
                        'Check analytics weekly to understand your productivity patterns',
                      ),
                      _buildTip(
                        '🎯',
                        'Start with 2-3 habits rather than trying to change everything at once',
                      ),
                      _buildTip(
                        '⏰',
                        'Set reminder times that align with your daily routine',
                      ),
                      _buildTip(
                        '🏆',
                        'Celebrate streak milestones to stay motivated',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Troubleshooting
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.build, color: Color(0xFF4A90E2)),
              title: const Text('Troubleshooting'),
              children: [
                _buildTroubleshootItem(
                  'Notifications not working',
                  'Check Settings > Reminder Settings and ensure notifications are enabled. Also verify app permissions in your device settings.',
                ),
                _buildTroubleshootItem(
                  'Data not saving',
                  'Ensure you have sufficient storage space. Try restarting the app or clearing app cache.',
                ),
                _buildTroubleshootItem(
                  'App running slowly',
                  'Try closing other apps, restart your device, or clear the app cache in device settings.',
                ),
                _buildTroubleshootItem(
                  'Sync issues',
                  'Check your internet connection and try refreshing the data by pulling down on the task list.',
                ),
              ],
            ),
          ),

          // Contact Support
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.support_agent,
                color: Color(0xFF4A90E2),
              ),
              title: const Text('Contact Support'),
              subtitle: const Text('Need more help? Get in touch with us'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showContactDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  Widget _buildFeatureGuide(String feature, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(feature, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildTroubleshootItem(String problem, String solution) {
    return ExpansionTile(
      title: Text(
        problem,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(solution, style: TextStyle(color: Colors.grey[600])),
        ),
      ],
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            Text('📧 support@tasksy.app'),
            Text('💬 In-app feedback'),
            Text('⭐ Rate us on app store'),
            SizedBox(height: 16),
            Text('We typically respond within 24 hours.'),
          ],
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
}
