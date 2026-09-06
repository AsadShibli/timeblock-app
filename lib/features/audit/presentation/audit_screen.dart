import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/audit_item.dart';
import '../providers/audit_providers.dart';
import 'audit_edit_sheet.dart';
import 'audit_tile.dart';

/// Tab 4: energy × value Audit list (Dan Martell matrix, mobile ListView).
class AuditScreen extends ConsumerWidget {
  const AuditScreen({super.key});

  Future<void> _openSheet(BuildContext context, WidgetRef ref, {AuditItem? initial}) async {
    final result = await showModalBottomSheet<AuditItem>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => AuditEditSheet(initial: initial),
    );
    if (result == null) return;

    if (initial == null) {
      await ref.read(auditActionsProvider.notifier).add(
            taskName: result.taskName,
            energy: result.energy,
            value: result.value,
          );
    } else {
      // Sheet preserves id when editing.
      await ref.read(auditActionsProvider.notifier).update(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(auditItemsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(context, ref),
        backgroundColor: const Color(0xFFB39DDB),
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: const TextStyle(color: Color(0xFFEF9A9A))),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No audit items yet',
                style: TextStyle(color: Colors.white38),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 88),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return AuditTile(
                item: item,
                onTap: () => _openSheet(context, ref, initial: item),
                onDelete: () {
                  ref.read(auditActionsProvider.notifier).delete(item.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
