import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/offline_write.dart';
import '../domain/wishlist_item.dart';

/// Real-time CRUD for global Wish List items (no date scoping).
class WishlistRepository {
  WishlistRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _items(String userId) {
    return _db.collection(FirestorePaths.wishlistItems(userId));
  }

  Stream<List<WishlistItem>> watchItems(String userId) {
    return _items(userId).orderBy('createdAt').snapshots().map(
          (snap) => snap.docs
              .map((d) => WishlistItem.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<String> addItem(String userId, String title) async {
    final now = DateTime.now().toIso8601String();
    // Was: await _items().add(...) — that waits for the server (UI freeze offline).
    final doc = _items(userId).doc();
    queueWrite(doc.set({
      'title': title.trim(),
      'createdAt': now,
      'isPriority': false,
    }));
    return doc.id;
  }

  Future<void> updateItem(String userId, WishlistItem item) async {
    // Was: return ...update() — that Future waited for the server.
    queueWrite(_items(userId).doc(item.id).update(item.toMap()));
  }

  Future<void> deleteItem(String userId, String itemId) async {
    // Was: return ...delete() — that Future waited for the server.
    queueWrite(_items(userId).doc(itemId).delete());
  }
}
