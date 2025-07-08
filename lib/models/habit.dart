class Habit {
  String id;
  String name;
  String description;
  String frequency;
  int streak;
  int targetCount;
  DateTime lastCompleted;
  List<DateTime> completedDates;
  String color;

  Habit({
    required this.id,
    required this.name,
    this.description = '',
    required this.frequency,
    this.streak = 0,
    this.targetCount = 1,
    required this.lastCompleted,
    required this.completedDates,
    this.color = 'blue',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'frequency': frequency,
    'streak': streak,
    'targetCount': targetCount,
    'lastCompleted': lastCompleted.toIso8601String(),
    'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
    'color': color,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'],
    name: json['name'],
    description: json['description'] ?? '',
    frequency: json['frequency'],
    streak: json['streak'],
    targetCount: json['targetCount'] ?? 1,
    lastCompleted: DateTime.parse(json['lastCompleted']),
    completedDates: (json['completedDates'] as List).map((d) => DateTime.parse(d)).toList(),
    color: json['color'] ?? 'blue',
  );

  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
  }

  double get progressPercentage {
    if (targetCount == 0) return 0.0;
    final today = DateTime.now();
    final todayCount = completedDates.where((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    ).length;
    return (todayCount / targetCount).clamp(0.0, 1.0);
  }
}