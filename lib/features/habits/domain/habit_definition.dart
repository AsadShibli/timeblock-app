/// Persistent habit definition (does not reset at midnight).
class HabitDefinition {
  const HabitDefinition({
    required this.id,
    required this.name,
    this.createdAt,
  });

  final String id;
  final String name;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': createdAt?.toIso8601String(),
      };

  factory HabitDefinition.fromMap(String id, Map<String, dynamic> map) {
    return HabitDefinition(
      id: id,
      name: map['name'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
    );
  }
}
