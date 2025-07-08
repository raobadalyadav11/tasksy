import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/popup_service.dart';
import '../services/popup_service.dart';

class TaskCreateScreen extends StatefulWidget {
  final Task? task;
  const TaskCreateScreen({super.key, this.task});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String selectedCategory = 'Personal';
  int selectedPriority = 1;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isRecurring = false;
  String recurrenceType = 'daily';
  
  final List<String> categories = ['Personal', 'Work', 'Health', 'Shopping', 'Study', 'Finance'];
  final List<String> priorities = ['Low', 'Medium', 'High'];
  final List<String> recurrenceTypes = ['daily', 'weekly', 'monthly'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      selectedCategory = widget.task!.category;
      selectedPriority = widget.task!.priority;
      selectedDate = widget.task!.dueDate;
      isRecurring = widget.task!.isRecurring;
      recurrenceType = widget.task!.recurrenceType;
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? finalDateTime;
    if (selectedDate != null) {
      finalDateTime = selectedDate!;
      if (selectedTime != null) {
        finalDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          selectedTime!.hour,
          selectedTime!.minute,
        );
      }
    }

    final task = Task(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: selectedCategory,
      priority: selectedPriority,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      dueDate: finalDateTime,
      isRecurring: isRecurring,
      recurrenceType: isRecurring ? recurrenceType : 'none',
      isCompleted: widget.task?.isCompleted ?? false,
    );

    if (widget.task != null) {
      await StorageService.updateTask(task);
      await NotificationService.cancelTaskReminder(task.id);
    } else {
      await StorageService.addTask(task);
    }

    // Schedule reminder if due date is set
    if (task.dueDate != null) {
      await NotificationService.scheduleTaskReminder(task);
      if (task.isRecurring) {
        await NotificationService.scheduleRecurringTaskReminder(task);
      }
    }

    Navigator.pop(context);
    
    if (widget.task != null) {
      PopupService.showToast('Task updated successfully');
    } else {
      PopupService.showTaskCreated(context, task.title);
    }
    
    if (widget.task != null) {
      PopupService.showToast('Task updated successfully');
    } else {
      PopupService.showTaskCreated(context, task.title);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task != null ? 'Edit Task' : 'Create Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title *',
                hintText: 'Enter task title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Category and Priority Row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: categories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedCategory = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedPriority,
                    decoration: InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.flag),
                    ),
                    items: priorities.asMap().entries.map((entry) => DropdownMenuItem(
                      value: entry.key + 1,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: [Colors.green, const Color(0xFFF5A623), Colors.red][entry.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(entry.value),
                        ],
                      ),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedPriority = value!),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Due Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(selectedDate != null 
                    ? 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                    : 'Set Due Date'),
                subtitle: selectedTime != null 
                    ? Text('Time: ${selectedTime!.format(context)}')
                    : null,
                trailing: selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() {
                          selectedDate = null;
                          selectedTime = null;
                        }),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: _selectDate,
              ),
            ),
            
            // Time (only if date is selected)
            if (selectedDate != null) ...[
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(selectedTime != null 
                      ? 'Time: ${selectedTime!.format(context)}'
                      : 'Set Time (Optional)'),
                  trailing: selectedTime != null 
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => selectedTime = null),
                        )
                      : const Icon(Icons.arrow_forward_ios),
                  onTap: _selectTime,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Recurring Task
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Recurring Task'),
                    subtitle: const Text('Repeat this task automatically'),
                    value: isRecurring,
                    onChanged: (value) => setState(() => isRecurring = value),
                    secondary: const Icon(Icons.repeat),
                  ),
                  if (isRecurring) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        value: recurrenceType,
                        decoration: InputDecoration(
                          labelText: 'Repeat',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: recurrenceTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        )).toList(),
                        onChanged: (value) => setState(() => recurrenceType = value!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.task != null ? 'Update Task' : 'Create Task',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}