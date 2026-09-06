/// Priority toggle for Brain Dump tasks.
/// Only [priority] tasks appear in the calendar create sheet.
enum TaskPriority {
  unlabeled, // default
  priority,
  nonPriority,
}

extension TaskPriorityX on TaskPriority {
  String get firestoreValue => name;

  static TaskPriority fromFirestore(String? value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => TaskPriority.unlabeled,
    );
  }
}
