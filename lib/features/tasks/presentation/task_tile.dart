import 'package:flutter/material.dart';

import '../domain/daily_task.dart';
import '../domain/task_priority.dart';

/// Brain Dump row: swipe delete, flag = priority, title = edit.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTogglePriority,
    required this.onEdit,
    required this.onDelete,
  });

  final DailyTask task;
  final VoidCallback onTogglePriority;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Phase 1: Firestore doc id as dismiss key.
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade800,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      // No ListTile.onTap — gestures are zone-isolated below.
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        // Phase 2: flag/circle only toggles priority.
        leading: InkWell(
          onTap: onTogglePriority,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: _PriorityDot(priority: task.priority),
          ),
        ),
        // Phase 2/3: title tap opens edit sheet.
        title: InkWell(
          onTap: onEdit,
          child: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              decoration: task.priority == TaskPriority.nonPriority
                  ? TextDecoration.lineThrough
                  : null,
              decorationColor: Colors.white38,
            ),
          ),
        ),
        subtitle: Text(
          _label(task.priority),
          style: const TextStyle(
            color: Color(0x99FFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  static String _label(TaskPriority p) => switch (p) {
        TaskPriority.priority => 'Priority',
        TaskPriority.nonPriority => 'Non-Priority',
        TaskPriority.unlabeled => 'Unlabeled',
      };

  static Color _color(TaskPriority p) => switch (p) {
        TaskPriority.priority => const Color(0xFFB39DDB),
        TaskPriority.nonPriority => Colors.white38,
        TaskPriority.unlabeled => Colors.white54,
      };
}

class _PriorityDot extends StatelessWidget {
  const _PriorityDot({required this.priority});
  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    return Icon(
      priority == TaskPriority.priority
          ? Icons.flag
          : priority == TaskPriority.nonPriority
              ? Icons.flag_outlined
              : Icons.circle_outlined,
      color: TaskTile._color(priority),
    );
  }
}
