import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firestore_paths.dart';
import '../../auth/providers/auth_providers.dart';
import '../../tasks/providers/task_providers.dart';
import '../data/habit_repository.dart';
import '../domain/habit_definition.dart';
import '../domain/habit_log.dart';
import '../domain/habit_repeat.dart';
import '../domain/habit_row.dart';

part 'habit_providers.g.dart';

@Riverpod(keepAlive: true)
HabitRepository habitRepository(Ref ref) => HabitRepository();

@riverpod
Stream<List<HabitDefinition>> habitDefinitions(Ref ref) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(habitRepositoryProvider).watchDefinitions(uid);
}

@riverpod
Stream<List<HabitLog>> todaysHabitLogs(Ref ref) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(habitRepositoryProvider).watchLogs(uid);
}

/// Combines definitions + today's logs into UI rows (instant stream updates).
@riverpod
AsyncValue<List<HabitRow>> todaysHabits(Ref ref) {
  final defsAsync = ref.watch(habitDefinitionsProvider);
  final logsAsync = ref.watch(todaysHabitLogsProvider);

  return defsAsync.when(
    loading: () => const AsyncLoading(),
    error: AsyncError.new,
    data: (defs) => logsAsync.when(
      loading: () => const AsyncLoading(),
      error: AsyncError.new,
      data: (logs) {
        final today = FirestorePaths.dateKey(DateTime.now());
        final logByHabit = {
          for (final l in logs)
            if (l.dateString == today) l.habitId: l.id,
        };
        return AsyncData([
          for (final d in defs)
            HabitRow(
              definition: d,
              todaysLogId: logByHabit[d.id],
              streak: habitStreak(
                {
                  for (final l in logs)
                    if (l.habitId == d.id) l.dateString,
                },
                DateTime.now(),
              ),
            ),
        ]);
      },
    ),
  );
}

@riverpod
class HabitActions extends _$HabitActions {
  @override
  void build() {}

  String? get _uid => ref.read(authSessionProvider);
  HabitRepository get _repo => ref.read(habitRepositoryProvider);
  String get _today => FirestorePaths.dateKey(DateTime.now());

  Future<void> add(String name) async {
    final uid = _uid;
    if (uid == null || name.trim().isEmpty) return;
    await _repo.addDefinition(uid, name);
  }

  /// Renames the habit; check-in logs are unchanged.
  Future<void> rename(String habitId, String name) async {
    final uid = _uid;
    final trimmed = name.trim();
    if (uid == null || trimmed.isEmpty) return;
    await _repo.updateDefinition(uid, habitId, trimmed);
  }

  Future<void> deleteDefinition(String habitId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteDefinition(uid, habitId);
  }

  /// Saves the calendar repeat and seeds Daily Task rows for matching days.
  Future<void> saveRepeat(HabitDefinition habit) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.saveDefinition(uid, habit);
    if (habit.repeatKind == HabitRepeatKind.none ||
        habit.repeatStart == null ||
        habit.repeatEnd == null) {
      return;
    }
    final days = habitRepeatDates(
      kind: habit.repeatKind,
      start: habit.repeatStart!,
      end: habit.repeatEnd!,
    );
    final tasks = ref.read(taskActionsProvider.notifier);
    for (final day in days) {
      await tasks.ensureHabitTask(
        FirestorePaths.dateKey(day),
        habit.id,
        habit.name,
      );
    }
  }

  /// Check-in ONLY — writes/deletes habit_logs for today (YYYY-MM-DD).
  /// Never mutates HabitDefinition; the habit list stays permanent day-to-day.
  Future<void> toggleToday(HabitRow row) async {
    final uid = _uid;
    if (uid == null) return;
    if (row.isCompletedToday) {
      // Uncheck: remove today's log document only.
      await _repo.deleteLog(uid, row.todaysLogId!);
    } else {
      // Check: add a log for today; definition is untouched.
      await _repo.addLog(uid, row.definition.id, _today);
    }
  }
}
