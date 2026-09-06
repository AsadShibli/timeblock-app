import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/presentation/edit_task_sheet.dart';
import '../domain/wishlist_item.dart';
import '../providers/wishlist_providers.dart';
import 'wishlist_tile.dart';

/// Tab 3: global Wish List — add / edit / swipe-delete (no priority/calendar).
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    await ref.read(wishlistActionsProvider.notifier).add(text);
    _input.clear();
  }

  Future<void> _edit(WishlistItem item) async {
    final updated = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => EditTaskSheet(
        initialTitle: item.title,
        heading: 'Edit wish',
        fieldLabel: 'Wish',
      ),
    );
    if (updated == null || !mounted) return;
    await ref.read(wishlistActionsProvider.notifier).rename(item, updated);
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(wishlistItemsProvider);

    return Stack(
      children: [
        // Native highlight/copy for wish titles (SelectionArea).
        Positioned.fill(
          child: SelectionArea(child: _buildList(itemsAsync)),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _FloatingInputRow(controller: _input, onSubmit: _add),
        ),
      ],
    );
  }

  Widget _buildList(AsyncValue<List<WishlistItem>> itemsAsync) {
    return itemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('$e', style: const TextStyle(color: Color(0xFFEF9A9A))),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No wishes yet',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 88),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return WishlistTile(
              item: item,
              onTogglePriority: () {
                ref.read(wishlistActionsProvider.notifier).setPriority(
                      item,
                      !item.isPriority,
                    );
              },
              onEdit: () => _edit(item),
              onDelete: () {
                ref.read(wishlistActionsProvider.notifier).delete(item.id);
              },
            );
          },
        );
      },
    );
  }
}

/// Same elevated input aesthetic as Brain Dump.
class _FloatingInputRow extends StatelessWidget {
  const _FloatingInputRow({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: const Color(0xFF1E1E1E),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                decoration: const InputDecoration(
                  hintText: 'Add a wish…',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            IconButton(
              onPressed: onSubmit,
              icon: const Icon(Icons.add, color: Color(0xFFB39DDB)),
            ),
          ],
        ),
      ),
    );
  }
}
