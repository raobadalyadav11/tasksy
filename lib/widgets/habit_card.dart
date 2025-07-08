import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onDelete,
    required this.onTap,
  });

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

    return Dismissible(
      key: Key(habit.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        habit.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: habitColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${habit.streak} days',
                        style: TextStyle(
                          color: habitColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (habit.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    habit.description,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(Icons.repeat, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      habit.frequency,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      'Target: ${habit.targetCount}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: habit.progressPercentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(habit.progressPercentage * 100).round()}%',
                      style: TextStyle(
                        color: habitColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: habit.isCompletedToday ? null : onComplete,
                    icon: Icon(
                      habit.isCompletedToday ? Icons.check_circle : Icons.add_circle,
                      size: 20,
                    ),
                    label: Text(
                      habit.isCompletedToday ? 'Completed Today!' : 'Mark Complete',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: habit.isCompletedToday ? Colors.green : habitColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}