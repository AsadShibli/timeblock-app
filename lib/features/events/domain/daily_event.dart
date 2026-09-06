import 'event_color.dart';

/// One calendar time block for a single day (Execution tab).
class DailyEvent {
  const DailyEvent({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
    this.color = EventColor.lavender,
    this.sourceTaskId,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime start;
  final DateTime end;
  final EventColor color;
  /// Optional link back to a Priority Brain Dump task.
  final String? sourceTaskId;

  DailyEvent copyWith({
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    EventColor? color,
    String? sourceTaskId,
  }) {
    return DailyEvent(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
      sourceTaskId: sourceTaskId ?? this.sourceTaskId,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'color': color.firestoreValue,
        'sourceTaskId': sourceTaskId,
      };

  factory DailyEvent.fromMap(String id, Map<String, dynamic> map) {
    return DailyEvent(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
      color: EventColor.fromFirestore(map['color'] as String?),
      sourceTaskId: map['sourceTaskId'] as String?,
    );
  }
}
