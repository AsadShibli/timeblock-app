import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/wishlist_repository.dart';
import '../domain/wishlist_item.dart';

part 'wishlist_providers.g.dart';

@Riverpod(keepAlive: true)
WishlistRepository wishlistRepository(Ref ref) => WishlistRepository();

/// Real-time global wishlist stream (all items for the unlocked user).
@riverpod
Stream<List<WishlistItem>> wishlistItems(Ref ref) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(wishlistRepositoryProvider).watchItems(uid);
}

/// Write helpers for Wish List (add / rename / delete) — no priority/calendar.
@riverpod
class WishlistActions extends _$WishlistActions {
  @override
  void build() {}

  String? get _uid => ref.read(authSessionProvider);
  WishlistRepository get _repo => ref.read(wishlistRepositoryProvider);

  Future<void> add(String title) async {
    final uid = _uid;
    if (uid == null || title.trim().isEmpty) return;
    await _repo.addItem(uid, title);
  }

  Future<void> rename(WishlistItem item, String title) async {
    final uid = _uid;
    final trimmed = title.trim();
    if (uid == null || trimmed.isEmpty) return;
    await _repo.updateItem(uid, item.copyWith(title: trimmed));
  }

  /// Toggles Wish List priority flag (UI only — no calendar sync).
  Future<void> setPriority(WishlistItem item, bool isPriority) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.updateItem(uid, item.copyWith(isPriority: isPriority));
  }

  Future<void> delete(String itemId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteItem(uid, itemId);
  }
}
