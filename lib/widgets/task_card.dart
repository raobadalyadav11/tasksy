import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColors = [Colors.green, const Color(0xFFF5A623), Colors.red];
    final isOverdue = task.dueDate != null && 
                     task.dueDate!.isBefore(DateTime.now()) && 
                     !task.isCompleted;

    return Dismissible(
      key: Key(task.id),
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
        elevation: task.isCompleted ? 1 : 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => onToggle(),
                  activeColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                
                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: task.isCompleted 
                              ? Colors.grey 
                              : isOverdue 
                                  ? Colors.red 
                                  : null,
                        ),
                      ),
                      
                      // Description
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: task.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Category and Due Date
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, 
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A90E2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              task.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A90E2),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                          // Due Date
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: isOverdue ? Colors.red : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: isOverdue ? Colors.red : Colors.grey[600],
                                fontWeight: isOverdue ? FontWeight.w600 : null,
                              ),
                            ),
                          ],
                          
                          // Recurring indicator
                          if (task.isRecurring) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.repeat,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Priority Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priorityColors[task.priority - 1],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) {
      return 'Today';
    } else if (taskDate == tomorrow) {
      return 'Tomorrow';
    } else if (taskDate.isBefore(today)) {
      final difference = today.difference(taskDate).inDays;
      return '$difference day${difference > 1 ? 's' : ''} ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}