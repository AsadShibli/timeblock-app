import 'package:flutter/material.dart';

/// Google Calendar–style dark-mode block colors.
enum EventColor {
  lavender(Color(0xFFB39DDB)),
  sage(Color(0xFFA5D6A7)),
  peacock(Color(0xFF80DEEA)),
  flamingo(Color(0xFFEF9A9A)),
  grape(Color(0xFFCE93D8));

  const EventColor(this.color);
  final Color color;

  String get firestoreValue => name;

  static EventColor fromFirestore(String? value) {
    return EventColor.values.firstWhere(
      (c) => c.name == value,
      orElse: () => EventColor.lavender,
    );
  }

  /// Cycles colors when assigning new blocks from priority tasks.
  static EventColor byIndex(int index) =>
      EventColor.values[index % EventColor.values.length];
}
