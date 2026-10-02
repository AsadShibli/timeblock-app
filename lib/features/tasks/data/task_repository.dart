import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/offline_write.dart';
import '../../audit/domain/audit_energy.dart';
import '../domain/daily_task.dart';
import '../domain/task_priority.dart';

/// Real-time CRUD for daily Brain Dump tasks in Firestore.
class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String userId, String dateKey) {
    return _db.collection(FirestorePaths.taskItems(userId, dateKey));
  }

  /// Live stream of all tasks for [userId] on [dateKey] (yyyy-MM-dd).
  Stream<List<DailyTask>> watchDailyTasks(String userId, String dateKey) {
    return _items(userId, dateKey)
        .orderBy('createdAt')
        .snapshots()
        .map((snap) {
          final tasks = snap.docs
              .map((d) => DailyTask.fromMap(d.id, d.data()))
              .toList();
          // Client sort: drag order first, then createdAt for old docs.
          tasks.sort((a, b) {
            final byOrder = a.sortOrder.compareTo(b.sortOrder);
            if (byOrder != 0) return byOrder;
            return (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0));
          });
          return tasks;
        });
  }

  /// Creates a task; returns the new document id.
  /// [sortOrder] appends to the bottom of the Brain Dump list.
  Future<String> addTask(
    String userId,
    String dateKey,
    String title, {
    int sortOrder = 0,
    String? habitId,
  }) async {
    final now = DateTime.now().toIso8601String();
    // Was: await _items().add({...}) — that waits for the server (UI freeze offline).
    // .doc() creates the id on-device; queueWrite syncs when online.
    final doc = _items(userId, dateKey).doc();
    queueWrite(doc.set({
      'title': title.trim(),
      'priority': TaskPriority.unlabeled.firestoreValue,
      // Same defaults as Audit so new Brain Dump tasks start Neutral / $1.
      'energy': AuditEnergy.neutral.firestoreValue,
      'value': 1,
      'sortOrder': sortOrder,
      'createdAt': now,
      'updatedAt': now,
      'habitId': ?habitId,
    }));
    // Stub so this dateKey shows up when listing days to clear.
    queueWrite(_db.doc(FirestorePaths.taskDay(userId, dateKey)).set({
      'exists': true,
    }, SetOptions(merge: true)));
    return doc.id;
  }

  Future<void> updateTask(String userId, String dateKey, DailyTask task) async {
    // Was: return ...update() — that Future waited for the server.
    queueWrite(_items(userId, dateKey).doc(task.id).update({
      ...task.toMap(),
      'updatedAt': DateTime.now().toIso8601String(),
    }));
  }

  Future<void> deleteTask(String userId, String dateKey, String taskId) async {
    // Was: return ...delete() — that Future waited for the server.
    queueWrite(_items(userId, dateKey).doc(taskId).delete());
  }

  /// Copies [task] to the bottom of [toDateKey], then removes it from [fromDateKey].
  Future<void> moveTask(
    String userId,
    String fromDateKey,
    String toDateKey,
    DailyTask task,
  ) async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _items(userId, toDateKey).get(const GetOptions(source: Source.cache));
    } catch (_) {
      snap = await _items(userId, toDateKey).get();
    }
    final doc = _items(userId, toDateKey).doc();
    final now = DateTime.now().toIso8601String();
    queueWrite(doc.set({
      ...task.toMap(),
      'sortOrder': snap.docs.length,
      'createdAt': now,
      'updatedAt': now,
    }));
    queueWrite(_db.doc(FirestorePaths.taskDay(userId, toDateKey)).set({
      'exists': true,
    }, SetOptions(merge: true)));
    queueWrite(_items(userId, fromDateKey).doc(task.id).delete());
  }

  /// Deletes every task on [dateKey], then the parent day stub.
  Future<void> deleteAllForDay(String userId, String dateKey) async {
    final snap = await _items(userId, dateKey).get();
    for (final d in snap.docs) {
      queueWrite(d.reference.delete());
    }
    queueWrite(_db.doc(FirestorePaths.taskDay(userId, dateKey)).delete());
  }

  /// Date keys that have a stub doc (new tasks after this feature).
  Future<List<String>> listDateKeys(String userId) async {
    final snap = await _db.collection(FirestorePaths.taskDays(userId)).get();
    return snap.docs.map((d) => d.id).toList();
  }

  /// Adds a habit-sourced task unless this day already has that habitId.
  Future<void> ensureHabitTask(
    String userId,
    String dateKey,
    String habitId,
    String title,
  ) async {
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await _items(userId, dateKey).get(const GetOptions(source: Source.cache));
    } catch (_) {
      snap = await _items(userId, dateKey).get();
    }
    if (snap.docs.any((d) => d.data()['habitId'] == habitId)) return;
    await addTask(userId, dateKey, title, sortOrder: snap.docs.length, habitId: habitId);
  }
}
