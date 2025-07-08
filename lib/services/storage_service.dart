import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/habit.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _habitsKey = 'habits';
  static const String _settingsKey = 'settings';
  static const String _firstTimeKey = 'first_time';

  // Task operations
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString(_tasksKey) ?? '[]';
    final tasksList = jsonDecode(tasksJson) as List;
    return tasksList.map((json) => Task.fromJson(json)).toList();
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_tasksKey, tasksJson);
  }

  static Future<void> addTask(Task task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  static Future<void> updateTask(Task updatedTask) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }

  static Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    await saveTasks(tasks);
  }

  // Habit operations
  static Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = prefs.getString(_habitsKey) ?? '[]';
    final habitsList = jsonDecode(habitsJson) as List;
    return habitsList.map((json) => Habit.fromJson(json)).toList();
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final habitsJson = jsonEncode(habits.map((habit) => habit.toJson()).toList());
    await prefs.setString(_habitsKey, habitsJson);
  }

  static Future<void> addHabit(Habit habit) async {
    final habits = await getHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  static Future<void> updateHabit(Habit updatedHabit) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      habits[index] = updatedHabit;
      await saveHabits(habits);
    }
  }

  static Future<void> deleteHabit(String habitId) async {
    final habits = await getHabits();
    habits.removeWhere((h) => h.id == habitId);
    await saveHabits(habits);
  }

  // Settings operations
  static Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey) ?? '{}';
    return jsonDecode(settingsJson) as Map<String, dynamic>;
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(settings);
    await prefs.setString(_settingsKey, settingsJson);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstTimeKey) ?? true;
  }

  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstTimeKey, value);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
    await prefs.remove(_habitsKey);
    await prefs.remove(_settingsKey);
  }
}