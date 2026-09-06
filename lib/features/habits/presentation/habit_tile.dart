import 'package:flutter/material.dart';

import '../domain/habit_row.dart';

/// Habit row: check-in circle (logs only) · selectable name · swipe deletes definition.
class HabitTile extends StatelessWidget {
  const HabitTile({
    super.key,
    required this.row,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final HabitRow row;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final done = row.isCompletedToday;
    return Dismissible(
      key: ValueKey(row.definition.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade800,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        // Check-in target: toggles habit_logs for today only.
        leading: GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Phase 3: solid green + check when logged today.
              color: done ? Colors.green : Colors.transparent,
              border: Border.all(
                color: done ? Colors.green : Colors.grey.shade800,
                width: 2,
              ),
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 22)
                : null,
          ),
        ),
        title: InkWell(
          onTap: onEdit,
          child: Text(
            row.definition.name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}
