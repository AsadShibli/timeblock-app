import 'task_priority.dart';

/// One Brain Dump task for a single calendar day.
class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    this.priority = TaskPriority.unlabeled,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final TaskPriority priority;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyTask copyWith({
    String? title,
    TaskPriority? priority,
  }) {
    return DailyTask(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Firestore map (id is the document id, not stored in the body).
  Map<String, dynamic> toMap() => {
        'title': title,
        'priority': priority.firestoreValue,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory DailyTask.fromMap(String id, Map<String, dynamic> map) {
    return DailyTask(
      id: id,
      title: map['title'] as String? ?? '',
      priority: TaskPriorityX.fromFirestore(map['priority'] as String?),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }
}
