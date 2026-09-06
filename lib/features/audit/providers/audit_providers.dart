import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/audit_repository.dart';
import '../domain/audit_energy.dart';
import '../domain/audit_item.dart';

part 'audit_providers.g.dart';

@Riverpod(keepAlive: true)
AuditRepository auditRepository(Ref ref) => AuditRepository();

/// Real-time Audit items for the unlocked user.
@riverpod
Stream<List<AuditItem>> auditItems(Ref ref) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(auditRepositoryProvider).watchItems(uid);
}

/// Write helpers for Audit (add / update / delete).
@riverpod
class AuditActions extends _$AuditActions {
  @override
  void build() {}

  String? get _uid => ref.read(authSessionProvider);
  AuditRepository get _repo => ref.read(auditRepositoryProvider);

  Future<void> add({
    required String taskName,
    required AuditEnergy energy,
    required int value,
  }) async {
    final uid = _uid;
    if (uid == null || taskName.trim().isEmpty) return;
    await _repo.addItem(
      uid,
      AuditItem(id: '', taskName: taskName, energy: energy, value: value),
    );
  }

  Future<void> update(AuditItem item) async {
    final uid = _uid;
    if (uid == null || item.taskName.trim().isEmpty) return;
    await _repo.updateItem(uid, item);
  }

  Future<void> delete(String itemId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteItem(uid, itemId);
  }
}
