import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import 'task_create_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task task;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  Future<void> _toggleTask() async {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    await StorageService.updateTask(task);
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
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
      await StorageService.deleteTask(task.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColors = [Colors.green, const Color(0xFFF5A623), Colors.red];
    final priorityNames = ['Low', 'Medium', 'High'];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskCreateScreen(task: task),
              ),
            ).then((_) => Navigator.pop(context)),
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(task.isCompleted ? Icons.undo : Icons.check),
                    const SizedBox(width: 8),
                    Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
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
                case 'toggle':
                  _toggleTask();
                  break;
                case 'delete':
                  _deleteTask();
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
              color: task.isCompleted ? Colors.green.withOpacity(0.1) : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: task.isCompleted ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.isCompleted ? 'Completed' : 'Pending',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: task.isCompleted ? Colors.green : Colors.orange,
                            ),
                          ),
                          Text(
                            task.isCompleted 
                                ? 'Great job! Task completed.'
                                : 'This task is still pending.',
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
            
            // Title
            Text(
              'Title',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Description
            if (task.description.isNotEmpty) ...[
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  task.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
            ],
            
            // Details Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildDetailCard(
                  'Category',
                  task.category,
                  Icons.category,
                  const Color(0xFF4A90E2),
                ),
                _buildDetailCard(
                  'Priority',
                  priorityNames[task.priority - 1],
                  Icons.flag,
                  priorityColors[task.priority - 1],
                ),
                _buildDetailCard(
                  'Created',
                  _formatDate(task.createdAt),
                  Icons.add_circle,
                  Colors.blue,
                ),
                if (task.dueDate != null)
                  _buildDetailCard(
                    'Due Date',
                    _formatDate(task.dueDate!),
                    Icons.schedule,
                    _isOverdue() ? Colors.red : Colors.orange,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Recurring Info
            if (task.isRecurring) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.repeat, color: Color(0xFF4A90E2)),
                  title: const Text('Recurring Task'),
                  subtitle: Text('Repeats ${task.recurrenceType}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      task.recurrenceType.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Overdue Warning
            if (_isOverdue()) ...[
              Card(
                color: Colors.red.withOpacity(0.1),
                child: const ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text(
                    'Overdue Task',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'This task is past its due date.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleTask,
                    icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                    label: Text(task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: task.isCompleted ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleteTask,
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

  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isOverdue() {
    return task.dueDate != null && 
           task.dueDate!.isBefore(DateTime.now()) && 
           !task.isCompleted;
  }
}