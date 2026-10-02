import '../../audit/domain/audit_energy.dart';
import 'task_priority.dart';

/// One Brain Dump task for a single calendar day.
class DailyTask {
  const DailyTask({
    required this.id,
    required this.title,
    this.priority = TaskPriority.unlabeled,
    this.energy = AuditEnergy.neutral,
    this.value = 1,
    this.sortOrder = 0,
    this.habitId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final TaskPriority priority;
  /// Same 3 energy types as Audit (Energizing / Neutral / Draining).
  final AuditEnergy energy;
  /// Same $1–$4 leverage band as Audit.
  final int value;
  /// List position; lower numbers sit closer to the top.
  final int sortOrder;
  /// Set when this row was created from a Habits schedule.
  final String? habitId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailyTask copyWith({
    String? title,
    TaskPriority? priority,
    AuditEnergy? energy,
    int? value,
    int? sortOrder,
    String? habitId,
  }) {
    return DailyTask(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      energy: energy ?? this.energy,
      value: value ?? this.value,
      sortOrder: sortOrder ?? this.sortOrder,
      habitId: habitId ?? this.habitId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Firestore map (id is the document id, not stored in the body).
  Map<String, dynamic> toMap() => {
        'title': title,
        'priority': priority.firestoreValue,
        'energy': energy.firestoreValue,
        'value': value,
        'sortOrder': sortOrder,
        'habitId': habitId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory DailyTask.fromMap(String id, Map<String, dynamic> map) {
    // Old docs may omit value/energy/sortOrder — match Audit defaults.
    final rawValue = map['value'];
    final parsedValue = rawValue is int ? rawValue : int.tryParse('$rawValue') ?? 1;
    final rawOrder = map['sortOrder'];
    final parsedOrder = rawOrder is int ? rawOrder : int.tryParse('$rawOrder') ?? 0;
    return DailyTask(
      id: id,
      title: map['title'] as String? ?? '',
      priority: TaskPriorityX.fromFirestore(map['priority'] as String?),
      energy: AuditEnergy.fromFirestore(map['energy'] as String?),
      value: parsedValue.clamp(1, 4),
      sortOrder: parsedOrder,
      habitId: map['habitId'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? ''),
    );
  }
}
