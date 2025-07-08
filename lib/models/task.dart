class Task {
  String id;
  String title;
  String description;
  String category;
  int priority;
  bool isCompleted;
  DateTime createdAt;
  DateTime? dueDate;
  bool isRecurring;
  String recurrenceType;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.priority = 1,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.isRecurring = false,
    this.recurrenceType = 'none',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'priority': priority,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'isRecurring': isRecurring,
    'recurrenceType': recurrenceType,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'],
    title: json['title'],
    description: json['description'] ?? '',
    category: json['category'],
    priority: json['priority'],
    isCompleted: json['isCompleted'],
    createdAt: DateTime.parse(json['createdAt']),
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    isRecurring: json['isRecurring'] ?? false,
    recurrenceType: json['recurrenceType'] ?? 'none',
  );
}