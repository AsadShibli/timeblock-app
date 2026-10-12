import 'package:flutter/material.dart';

import '../domain/daily_task.dart';
import '../domain/task_priority.dart';

/// Brain Dump row: swipe right = next day, swipe left = delete, flag = priority, title = edit.
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTogglePriority,
    required this.onEdit,
    required this.onSetDuration,
    required this.onDelete,
    required this.onMoveToNextDay,
    this.dragHandle,
  });

  final DailyTask task;
  final VoidCallback onTogglePriority;
  final VoidCallback onEdit;
  /// Called with 15/30/45/60, or null to clear.
  final ValueChanged<int?> onSetDuration;
  final VoidCallback onDelete;
  final VoidCallback onMoveToNextDay;
  /// Web/desktop drag affordance; null when the row is not reorderable.
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Phase 1: Firestore doc id as dismiss key.
      key: ValueKey(task.id),
      direction: DismissDirection.horizontal,
      // Swipe right -> move to next day.
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.indigo.shade700,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_forward, color: Colors.white),
            SizedBox(width: 8),
            Text('Tomorrow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      // Swipe left -> delete.
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade800,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (dir) => dir == DismissDirection.startToEnd
          ? onMoveToNextDay()
          : onDelete(),
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
        // Same $ badge + energy dot as Audit tiles.
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DurationChip(minutes: task.durationMinutes, onSelected: onSetDuration),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '\$${task.value}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: task.energy.color,
                shape: BoxShape.circle,
              ),
            ),
            if (dragHandle != null) ...[
              const SizedBox(width: 8),
              dragHandle!,
            ],
          ],
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

/// Tappable duration pill: shows "30m" or a timer icon; menu offers presets.
class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.minutes, required this.onSelected});

  final int? minutes;
  final ValueChanged<int?> onSelected;

  static const presets = [15, 30, 45, 60];

  @override
  Widget build(BuildContext context) {
    final set = minutes != null;
    return PopupMenuButton<int>(
      tooltip: 'Duration',
      color: const Color(0xFF1E1E1E),
      padding: EdgeInsets.zero,
      // 0 = clear (presets are all > 0).
      onSelected: (m) => onSelected(m == 0 ? null : m),
      itemBuilder: (_) => [
        for (final m in presets)
          CheckedPopupMenuItem<int>(
            value: m,
            checked: minutes == m,
            child: Text('$m min', style: const TextStyle(color: Colors.white)),
          ),
        if (set)
          const PopupMenuItem<int>(
            value: 0,
            child: Text('Clear', style: TextStyle(color: Colors.white54)),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: set ? const Color(0x33B39DDB) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined,
                size: 14, color: set ? const Color(0xFFB39DDB) : Colors.white38),
            if (set) ...[
              const SizedBox(width: 4),
              Text('${minutes}m',
                  style: const TextStyle(
                      color: Color(0xFFB39DDB),
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}
