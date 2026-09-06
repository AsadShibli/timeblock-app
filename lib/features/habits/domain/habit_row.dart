import 'habit_definition.dart';

/// UI row: habit definition + optional today's completion log id.
class HabitRow {
  const HabitRow({
    required this.definition,
    this.todaysLogId,
  });

  final HabitDefinition definition;
  /// Non-null when completed today.
  final String? todaysLogId;

  bool get isCompletedToday => todaysLogId != null;
}
