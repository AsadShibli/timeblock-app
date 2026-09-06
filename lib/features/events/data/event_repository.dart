import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/offline_write.dart';
import '../domain/daily_event.dart';

/// Real-time CRUD for daily calendar time blocks in Firestore.
class EventRepository {
  EventRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String userId, String dateKey) {
    return _db.collection(FirestorePaths.eventItems(userId, dateKey));
  }

  /// Live stream of time blocks for [userId] on [dateKey] (yyyy-MM-dd).
  Stream<List<DailyEvent>> watchDailyEvents(String userId, String dateKey) {
    return _items(userId, dateKey)
        .orderBy('start')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DailyEvent.fromMap(d.id, d.data()))
            .toList());
  }

  /// Creates a time block; returns the new document id.
  Future<String> addEvent(String userId, String dateKey, DailyEvent event) async {
    // Was: await _items().add(...) — that waits for the server (UI freeze offline).
    final doc = _items(userId, dateKey).doc();
    queueWrite(doc.set(event.toMap()));
    return doc.id;
  }

  Future<void> updateEvent(String userId, String dateKey, DailyEvent event) async {
    // Was: return ...update() — that Future waited for the server.
    queueWrite(_items(userId, dateKey).doc(event.id).update(event.toMap()));
  }

  Future<void> deleteEvent(String userId, String dateKey, String eventId) async {
    // Was: return ...delete() — that Future waited for the server.
    queueWrite(_items(userId, dateKey).doc(eventId).delete());
  }
}
