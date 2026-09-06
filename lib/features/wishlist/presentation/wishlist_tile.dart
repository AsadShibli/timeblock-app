import 'package:flutter/material.dart';

import '../domain/wishlist_item.dart';

/// Wish List row: priority toggle · tap title to edit · swipe delete.
class WishlistTile extends StatelessWidget {
  const WishlistTile({
    super.key,
    required this.item,
    required this.onTogglePriority,
    required this.onEdit,
    required this.onDelete,
  });

  final WishlistItem item;
  final VoidCallback onTogglePriority;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade800,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // Leading icon toggles priority (isolated from title edit).
        leading: GestureDetector(
          onTap: onTogglePriority,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              item.isPriority ? Icons.star : Icons.circle_outlined,
              color: item.isPriority
                  ? const Color(0xFFB39DDB)
                  : Colors.white54,
            ),
          ),
        ),
        title: InkWell(
          onTap: onEdit,
          child: Text(
            item.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
