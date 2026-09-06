import 'package:flutter/material.dart';

/// Emotional energy for the Audit matrix (Dan Martell style).
enum AuditEnergy {
  positive, // Energizing — green
  neutral, // Neutral — grey
  negative; // Draining — red

  String get firestoreValue => name;

  String get label => switch (this) {
        AuditEnergy.positive => 'Energizing',
        AuditEnergy.neutral => 'Neutral',
        AuditEnergy.negative => 'Draining',
      };

  Color get color => switch (this) {
        AuditEnergy.positive => Colors.green,
        AuditEnergy.neutral => Colors.grey,
        AuditEnergy.negative => Colors.red,
      };

  static AuditEnergy fromFirestore(String? value) {
    return AuditEnergy.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuditEnergy.neutral,
    );
  }
}
