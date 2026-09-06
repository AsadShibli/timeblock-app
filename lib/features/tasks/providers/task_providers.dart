import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_providers.dart';
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

  Future<void> add(String dateKey, String title) async {
    final uid = _uid;
    if (uid == null || title.trim().isEmpty) return;
    await _repo.addTask(uid, dateKey, title);
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

  Future<void> delete(String dateKey, String taskId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteTask(uid, dateKey, taskId);
  }
}
