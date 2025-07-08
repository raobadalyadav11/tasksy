class Validators {
  static String? validateTaskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a task title';
    }
    if (value.trim().length < 2) {
      return 'Task title must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return 'Task title must be less than 100 characters';
    }
    return null;
  }

  static String? validateHabitName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a habit name';
    }
    if (value.trim().length < 2) {
      return 'Habit name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Habit name must be less than 50 characters';
    }
    return null;
  }

  static String? validateTargetCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter target count';
    }
    final count = int.tryParse(value);
    if (count == null) {
      return 'Please enter a valid number';
    }
    if (count < 1) {
      return 'Target count must be at least 1';
    }
    if (count > 100) {
      return 'Target count must be less than 100';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidTime(String time) {
    return RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(time);
  }

  static bool isValidDate(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return date.isAfter(now.subtract(const Duration(days: 1)));
  }
}