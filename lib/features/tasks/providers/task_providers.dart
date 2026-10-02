import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/firestore_paths.dart';
import '../../auth/providers/auth_providers.dart';
import '../../audit/domain/audit_energy.dart';
import '../../habits/domain/habit_definition.dart';
import '../../habits/domain/habit_repeat.dart';
import '../data/task_repository.dart';
import '../domain/daily_task.dart';
import '../domain/task_priority.dart';

part 'task_providers.g.dart';

@Riverpod(keepAlive: true)
TaskRepository taskRepository(Ref ref) => TaskRepository();

/// Real-time tasks for a day. [dateKey] format: yyyy-MM-dd.
@riverpod
Stream<List<DailyTask>> dailyTasks(Ref ref, String dateKey) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(taskRepositoryProvider).watchDailyTasks(uid, dateKey);
}

/// Priority-only tasks for the calendar bottom sheet.
@riverpod
Stream<List<DailyTask>> priorityTasks(Ref ref, String dateKey) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  // Same Firestore stream as dailyTasks, filtered client-side.
  return ref.watch(taskRepositoryProvider).watchDailyTasks(uid, dateKey).map(
        (tasks) =>
            tasks.where((t) => t.priority == TaskPriority.priority).toList(),
      );
}

/// Write helpers for tasks (create / toggle / delete).
@riverpod
class TaskActions extends _$TaskActions {
  @override
  void build() {}

  String? get _uid => ref.read(authSessionProvider);
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  Future<void> add(String dateKey, String title, {int sortOrder = 0, String? habitId}) async {
    final uid = _uid;
    if (uid == null || title.trim().isEmpty) return;
    await _repo.addTask(uid, dateKey, title, sortOrder: sortOrder, habitId: habitId);
  }

  Future<void> setPriority(
    String dateKey,
    DailyTask task,
    TaskPriority priority,
  ) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.updateTask(uid, dateKey, task.copyWith(priority: priority));
  }

  /// Renames a task (Brain Dump edit sheet).
  Future<void> rename(String dateKey, DailyTask task, String title) async {
    final uid = _uid;
    final trimmed = title.trim();
    if (uid == null || trimmed.isEmpty) return;
    await _repo.updateTask(uid, dateKey, task.copyWith(title: trimmed));
  }

  /// Saves title + $ leverage + energy from the Brain Dump edit sheet.
  Future<void> updateDetails(
    String dateKey,
    DailyTask task, {
    required String title,
    required AuditEnergy energy,
    required int value,
  }) async {
    final uid = _uid;
    final trimmed = title.trim();
    if (uid == null || trimmed.isEmpty) return;
    await _repo.updateTask(
      uid,
      dateKey,
      task.copyWith(title: trimmed, energy: energy, value: value),
    );
  }

  /// Writes 0..n-1 sortOrder after a drag-reorder in Brain Dump.
  Future<void> reorder(String dateKey, List<DailyTask> ordered) async {
    final uid = _uid;
    if (uid == null) return;
    for (var i = 0; i < ordered.length; i++) {
      final task = ordered[i];
      if (task.sortOrder == i) continue;
      await _repo.updateTask(uid, dateKey, task.copyWith(sortOrder: i));
    }
  }

  Future<void> delete(String dateKey, String taskId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteTask(uid, dateKey, taskId);
  }

  /// Swipe-right: moves a task to the following calendar day.
  Future<void> moveToNextDay(String dateKey, DailyTask task) async {
    final uid = _uid;
    if (uid == null) return;
    final d = DateTime.parse(dateKey);
    final next = DateTime(d.year, d.month, d.day + 1);
    await _repo.moveTask(uid, dateKey, FirestorePaths.dateKey(next), task);
  }

  /// Wipe every Brain Dump task for one calendar day.
  Future<void> deleteAll(String dateKey) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteAllForDay(uid, dateKey);
  }

  /// Wipe stubbed days strictly before [cutoffDateKey] (yyyy-MM-dd).
  Future<void> deleteEarlierThan(String cutoffDateKey) async {
    final uid = _uid;
    if (uid == null) return;
    final keys = await _repo.listDateKeys(uid);
    for (final key in keys) {
      if (key.compareTo(cutoffDateKey) < 0) {
        await _repo.deleteAllForDay(uid, key);
      }
    }
  }

  /// Creates a Daily Task from a habit if this day does not already have one.
  Future<void> ensureHabitTask(
    String dateKey,
    String habitId,
    String title,
  ) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.ensureHabitTask(uid, dateKey, habitId, title);
  }

  Future<void> ensureHabitsForDay(
    String dateKey,
    List<HabitDefinition> habits,
  ) async {
    final uid = _uid;
    if (uid == null) return;
    DateTime? day;
    try {
      day = DateTime.parse(dateKey);
    } catch (_) {
      return;
    }
    for (final h in habits) {
      if (!habitAppliesOnDate(
        kind: h.repeatKind,
        start: h.repeatStart,
        end: h.repeatEnd,
        day: day,
      )) {
        continue;
      }
      await _repo.ensureHabitTask(uid, dateKey, h.id, h.name);
    }
  }
}
