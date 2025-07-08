import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import 'habit_create_screen.dart';

class HabitDetailScreen extends StatefulWidget {
  final Habit habit;
  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late Habit habit;

  @override
  void initState() {
    super.initState();
    habit = widget.habit;
  }

  Future<void> _markComplete() async {
    if (!habit.isCompletedToday) {
      final today = DateTime.now();
      habit.completedDates.add(today);
      habit.streak++;
      habit.lastCompleted = today;
      
      await StorageService.updateHabit(habit);
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${habit.name} completed! Streak: ${habit.streak} days')),
      );
    }
  }

  Future<void> _deleteHabit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: const Text('Are you sure you want to delete this habit? This will remove all progress data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteHabit(habit.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      'blue': Colors.blue,
      'green': Colors.green,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'red': Colors.red,
    };
    final habitColor = colorMap[habit.color] ?? Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HabitCreateScreen(habit: habit)),
            ).then((_) => Navigator.pop(context)),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'complete',
                enabled: !habit.isCompletedToday,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle),
                    const SizedBox(width: 8),
                    Text(habit.isCompletedToday ? 'Already Completed' : 'Mark Complete'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'complete':
                  _markComplete();
                  break;
                case 'delete':
                  _deleteHabit();
                  break;
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: habit.isCompletedToday ? Colors.green.withOpacity(0.1) : habitColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: habit.isCompletedToday ? Colors.green : habitColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        habit.isCompletedToday ? Icons.check_circle : Icons.track_changes,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.isCompletedToday ? 'Completed Today!' : 'Ready to Complete',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: habit.isCompletedToday ? Colors.green : habitColor,
                            ),
                          ),
                          Text(
                            habit.isCompletedToday 
                                ? 'Great job maintaining your streak!'
                                : 'Complete this habit to continue your streak.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Habit Name
            Text(
              habit.name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 8),
            
            if (habit.description.isNotEmpty) ...[
              Text(
                habit.description,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
            ],
            
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard('Current Streak', '${habit.streak} days', Icons.local_fire_department, Colors.orange),
                _buildStatCard('Frequency', habit.frequency, Icons.repeat, Colors.blue),
                _buildStatCard('Target Count', '${habit.targetCount}', Icons.flag, Colors.green),
                _buildStatCard('Total Completed', '${habit.completedDates.length}', Icons.check_circle, Colors.purple),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Progress Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Progress',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: habit.progressPercentage,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(habit.progressPercentage * 100).round()}%',
                          style: TextStyle(
                            color: habitColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recent Activity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (habit.completedDates.isEmpty)
                      const Text('No activity yet. Start building your habit!')
                    else
                      ...habit.completedDates.take(7).map((date) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: habitColor, size: 20),
                            const SizedBox(width: 8),
                            Text('Completed on ${_formatDate(date)}'),
                          ],
                        ),
                      )).toList(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: habit.isCompletedToday ? null : _markComplete,
                    icon: const Icon(Icons.check_circle),
                    label: Text(habit.isCompletedToday ? 'Completed Today' : 'Mark Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: habit.isCompletedToday ? Colors.grey : habitColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteHabit,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}