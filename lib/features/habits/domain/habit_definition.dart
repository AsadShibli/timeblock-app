import '../../../core/firestore_paths.dart';
import 'habit_repeat.dart';

/// Persistent habit definition (does not reset at midnight).
class HabitDefinition {
  const HabitDefinition({
    required this.id,
    required this.name,
    this.createdAt,
    this.repeatKind = HabitRepeatKind.none,
    this.repeatStart,
    this.repeatEnd,
  });

  final String id;
  final String name;
  final DateTime? createdAt;
  /// When set, matching days get this habit as a Daily Task.
  final HabitRepeatKind repeatKind;
  final DateTime? repeatStart;
  final DateTime? repeatEnd;

  HabitDefinition copyWith({
    String? name,
    HabitRepeatKind? repeatKind,
    DateTime? repeatStart,
    DateTime? repeatEnd,
  }) {
    return HabitDefinition(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      repeatKind: repeatKind ?? this.repeatKind,
      repeatStart: repeatStart ?? this.repeatStart,
      repeatEnd: repeatEnd ?? this.repeatEnd,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': createdAt?.toIso8601String(),
        'repeatKind': repeatKind.firestoreValue,
        'repeatStart':
            repeatStart == null ? null : FirestorePaths.dateKey(repeatStart!),
        'repeatEnd':
            repeatEnd == null ? null : FirestorePaths.dateKey(repeatEnd!),
      };

  factory HabitDefinition.fromMap(String id, Map<String, dynamic> map) {
    return HabitDefinition(
      id: id,
      name: map['name'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      repeatKind: HabitRepeatKind.fromFirestore(map['repeatKind'] as String?),
      repeatStart: DateTime.tryParse(map['repeatStart'] as String? ?? ''),
      repeatEnd: DateTime.tryParse(map['repeatEnd'] as String? ?? ''),
    );
  }
}
