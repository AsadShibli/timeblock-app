import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/offline_write.dart';
import '../domain/audit_item.dart';

/// Real-time CRUD for Audit matrix items: audit/{userId}/items.
class AuditRepository {
  AuditRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String userId) {
    return _db.collection(FirestorePaths.auditItems(userId));
  }

  Stream<List<AuditItem>> watchItems(String userId) {
    return _items(userId).snapshots().map(
          (snap) => snap.docs
              .map((d) => AuditItem.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<String> addItem(String userId, AuditItem item) async {
    // Was: await _items().add(...) — that waits for the server (UI freeze offline).
    final doc = _items(userId).doc();
    queueWrite(doc.set({
      'taskName': item.taskName.trim(),
      'energy': item.energy.firestoreValue,
      'value': item.value,
    }));
    return doc.id;
  }

  Future<void> updateItem(String userId, AuditItem item) async {
    // Was: return ...update() — that Future waited for the server.
    queueWrite(_items(userId).doc(item.id).update(item.toMap()));
  }

  Future<void> deleteItem(String userId, String itemId) async {
    // Was: return ...delete() — that Future waited for the server.
    queueWrite(_items(userId).doc(itemId).delete());
  }
}
