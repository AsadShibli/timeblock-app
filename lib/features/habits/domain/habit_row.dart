import 'habit_definition.dart';

/// UI row: habit definition + optional today's completion log id.
class HabitRow {
  const HabitRow({
    required this.definition,
    this.todaysLogId,
    this.streak = 0,
  });

  final HabitDefinition definition;
  /// Non-null when completed today.
  final String? todaysLogId;
  /// Consecutive completed days (today optional).
  final int streak;

  bool get isCompletedToday => todaysLogId != null;
}
