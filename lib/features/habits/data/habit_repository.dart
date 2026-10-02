import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/offline_write.dart';
import '../domain/habit_definition.dart';
import '../domain/habit_log.dart';

/// CRUD for habit definitions + daily completion logs (no midnight cron).
class HabitRepository {
  HabitRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _defs(String userId) =>
      _db.collection(FirestorePaths.habitItems(userId));

  CollectionReference<Map<String, dynamic>> _logs(String userId) =>
      _db.collection(FirestorePaths.habitLogs(userId));

  Stream<List<HabitDefinition>> watchDefinitions(String userId) {
    return _defs(userId).orderBy('createdAt').snapshots().map(
          (snap) => snap.docs
              .map((d) => HabitDefinition.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// Today's logs only: where dateString == YYYY-MM-DD.
  Stream<List<HabitLog>> watchLogsForDate(String userId, String dateString) {
    return _logs(userId)
        .where('dateString', isEqualTo: dateString)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => HabitLog.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  /// All logs (used for streaks + today's check-in).
  Stream<List<HabitLog>> watchLogs(String userId) {
    return _logs(userId).snapshots().map(
          (snap) => snap.docs
              .map((d) => HabitLog.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<String> addDefinition(String userId, String name) async {
    // Was: await _defs().add(...) — that waits for the server (UI freeze offline).
    final doc = _defs(userId).doc();
    queueWrite(doc.set({
      'name': name.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    }));
    return doc.id;
  }

  /// Renames a habit definition (logs stay linked by id).
  Future<void> updateDefinition(
    String userId,
    String habitId,
    String name,
  ) async {
    queueWrite(_defs(userId).doc(habitId).update({
      'name': name.trim(),
    }));
  }

  /// Saves name + repeat window (calendar schedule).
  Future<void> saveDefinition(String userId, HabitDefinition habit) async {
    queueWrite(_defs(userId).doc(habit.id).update(habit.toMap()));
  }

  Future<void> deleteDefinition(String userId, String habitId) async {
    // Was: await delete + await get() + await batch — hangs offline.
    queueWrite(_defs(userId).doc(habitId).delete());
    // Cache-only so we don't wait on the network. Logs never cached stay until later.
    try {
      final logs = await _logs(userId)
          .where('habitId', isEqualTo: habitId)
          .get(const GetOptions(source: Source.cache));
      for (final doc in logs.docs) {
        queueWrite(doc.reference.delete());
      }
    } catch (_) {
      // No cached logs while offline; definition delete is already queued.
    }
  }

  Future<String> addLog(String userId, String habitId, String dateString) async {
    // Was: await _logs().add(...) — that waits for the server (UI freeze offline).
    final doc = _logs(userId).doc();
    queueWrite(doc.set({
      'habitId': habitId,
      'dateString': dateString,
    }));
    return doc.id;
  }

  Future<void> deleteLog(String userId, String logId) async {
    // Was: return ...delete() — that Future waited for the server.
    queueWrite(_logs(userId).doc(logId).delete());
  }
}
