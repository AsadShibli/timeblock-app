import 'audit_energy.dart';

/// One Audit matrix item: task × energy × dollar leverage.
class AuditItem {
  const AuditItem({
    required this.id,
    required this.taskName,
    this.energy = AuditEnergy.neutral,
    this.value = 1,
  });

  final String id;
  final String taskName;
  final AuditEnergy energy;
  /// Financial leverage band: 1–4 ($1 … $4).
  final int value;

  AuditItem copyWith({
    String? taskName,
    AuditEnergy? energy,
    int? value,
  }) {
    return AuditItem(
      id: id,
      taskName: taskName ?? this.taskName,
      energy: energy ?? this.energy,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() => {
        'taskName': taskName,
        'energy': energy.firestoreValue,
        'value': value,
      };

  factory AuditItem.fromMap(String id, Map<String, dynamic> map) {
    final rawValue = map['value'];
    final parsed = rawValue is int ? rawValue : int.tryParse('$rawValue') ?? 1;
    return AuditItem(
      id: id,
      taskName: map['taskName'] as String? ?? '',
      energy: AuditEnergy.fromFirestore(map['energy'] as String?),
      value: parsed.clamp(1, 4),
    );
  }
}
