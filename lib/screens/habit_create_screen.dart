import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class HabitCreateScreen extends StatefulWidget {
  final Habit? habit;
  const HabitCreateScreen({super.key, this.habit});

  @override
  State<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends State<HabitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String selectedFrequency = 'Daily';
  int targetCount = 1;
  String selectedColor = 'blue';
  TimeOfDay? reminderTime;
  
  final List<String> frequencies = ['Daily', 'Weekly', 'Monthly'];
  final Map<String, Color> colors = {
    'blue': Colors.blue,
    'green': Colors.green,
    'orange': Colors.orange,
    'purple': Colors.purple,
    'red': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description;
      selectedFrequency = widget.habit!.frequency;
      targetCount = widget.habit!.targetCount;
      selectedColor = widget.habit!.color;
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      id: widget.habit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      frequency: selectedFrequency,
      targetCount: targetCount,
      color: selectedColor,
      lastCompleted: widget.habit?.lastCompleted ?? DateTime.now().subtract(const Duration(days: 1)),
      completedDates: widget.habit?.completedDates ?? [],
      streak: widget.habit?.streak ?? 0,
    );

    if (widget.habit != null) {
      await StorageService.updateHabit(habit);
      await NotificationService.cancelHabitReminder(habit.id);
    } else {
      await StorageService.addHabit(habit);
    }

    // Schedule reminder if time is set
    if (reminderTime != null) {
      await NotificationService.scheduleHabitReminder(habit, reminderTime!);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit != null ? 'Edit Habit' : 'Create Habit'),
        actions: [
          TextButton(
            onPressed: _saveHabit,
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
            // Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Habit Name *',
                hintText: 'e.g., Drink 8 glasses of water',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.track_changes),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
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
                hintText: 'Optional description or notes',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Frequency and Target Count
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration: InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.repeat),
                    ),
                    items: frequencies.map((freq) => DropdownMenuItem(
                      value: freq,
                      child: Text(freq),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedFrequency = value!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: targetCount.toString(),
                    decoration: InputDecoration(
                      labelText: 'Target Count',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.flag),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || int.tryParse(value) == null || int.parse(value) < 1) {
                        return 'Enter valid number';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final count = int.tryParse(value);
                      if (count != null && count > 0) {
                        targetCount = count;
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Reminder Time
            Card(
              child: ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(reminderTime != null 
                    ? 'Reminder: ${reminderTime!.format(context)}'
                    : 'Set Reminder Time'),
                subtitle: const Text('Get notified to complete this habit'),
                trailing: reminderTime != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => reminderTime = null),
                      )
                    : const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: reminderTime ?? TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() => reminderTime = time);
                  }
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Color Selection
            const Text(
              'Choose Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: colors.entries.map((entry) {
                final isSelected = selectedColor == entry.key;
                return GestureDetector(
                  onTap: () => setState(() => selectedColor = entry.key),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors[selectedColor],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  widget.habit != null ? 'Update Habit' : 'Create Habit',
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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}