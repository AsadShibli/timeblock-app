import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/offline_write.dart';
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
        .map((snap) => snap.docs
            .map((d) => DailyTask.fromMap(d.id, d.data()))
            .toList());
  }

  /// Creates a task; returns the new document id.
  Future<String> addTask(String userId, String dateKey, String title) async {
    final now = DateTime.now().toIso8601String();
    // Was: await _items().add({...}) — that waits for the server (UI freeze offline).
    // .doc() creates the id on-device; queueWrite syncs when online.
    final doc = _items(userId, dateKey).doc();
    queueWrite(doc.set({
      'title': title.trim(),
      'priority': TaskPriority.unlabeled.firestoreValue,
      'createdAt': now,
      'updatedAt': now,
    }));
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
}
