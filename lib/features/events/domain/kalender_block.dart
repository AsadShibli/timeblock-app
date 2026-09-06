import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

import 'daily_event.dart';
import 'event_color.dart';

/// Kalender tile model backed by our Firestore [DailyEvent].
class KalenderBlock extends CalendarEvent {
  KalenderBlock({
    required String id,
    required super.dateTimeRange,
    required this.title,
    this.description,
    this.color = EventColor.lavender,
    this.sourceTaskId,
  }) : super(id: id);

  final String title;
  final String? description;
  final EventColor color;
  final String? sourceTaskId;

  factory KalenderBlock.fromDaily(DailyEvent e) {
    return KalenderBlock(
      id: e.id,
      dateTimeRange: DateTimeRange(start: e.start, end: e.end),
      title: e.title,
      description: e.description,
      color: e.color,
      sourceTaskId: e.sourceTaskId,
    );
  }

  DailyEvent toDaily() {
    return DailyEvent(
      id: id,
      title: title,
      description: description,
      start: start.toLocal(),
      end: end.toLocal(),
      color: color,
      sourceTaskId: sourceTaskId,
    );
  }

  @override
  KalenderBlock copyWith({
    DateTimeRange? dateTimeRange,
    EventInteraction? interaction,
    String? title,
    String? description,
    EventColor? color,
    String? sourceTaskId,
  }) {
    return KalenderBlock(
      id: id,
      dateTimeRange: dateTimeRange ?? DateTimeRange(start: start, end: end),
      title: title ?? this.title,
      description: description ?? this.description,
      color: color ?? this.color,
      sourceTaskId: sourceTaskId ?? this.sourceTaskId,
    );
  }

  @override
  bool operator ==(Object other) {
    return super == other &&
        other is KalenderBlock &&
        other.title == title &&
        other.description == description &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, title, description, color);
}
