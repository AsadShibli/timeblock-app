import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/brain_dump_day_provider.dart';
import '../../../core/firestore_paths.dart';
import '../../../core/planning_day.dart';
// Brain Dump uses noon-based planning day, not calendar midnight selectedDay.
// import '../../../core/selected_day_provider.dart';
import '../../habits/providers/habit_providers.dart';
import '../domain/daily_task.dart';
import '../domain/task_priority.dart';
import '../providers/task_providers.dart';
import 'edit_task_sheet.dart';
import 'task_tile.dart';

/// Tab 1: quick-capture daily tasks bound to Firestore streams.
class BrainDumpScreen extends ConsumerStatefulWidget {
  const BrainDumpScreen({super.key});

  @override
  ConsumerState<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends ConsumerState<BrainDumpScreen> {
  final _input = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncHabits());
  }

  void _syncHabits() {
    final defs = ref.read(habitDefinitionsProvider).value;
    if (defs == null) return;
    ref.read(taskActionsProvider.notifier).ensureHabitsForDay(_dateKey, defs);
  }

  String get _dateKey =>
      FirestorePaths.dateKey(ref.read(brainDumpDayProvider));

  Future<void> _add() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    final dateKey = _dateKey;
    // Append to the bottom of the current list.
    final tasks = ref.read(dailyTasksProvider(dateKey)).value ?? [];
    await ref.read(taskActionsProvider.notifier).add(
          dateKey,
          text,
          sortOrder: tasks.length,
        );
    _input.clear();
  }

  /// unlabeled -> priority -> nonPriority -> unlabeled
  TaskPriority _next(TaskPriority current) => switch (current) {
        TaskPriority.unlabeled => TaskPriority.priority,
        TaskPriority.priority => TaskPriority.nonPriority,
        TaskPriority.nonPriority => TaskPriority.unlabeled,
      };

  /// Title tap → edit sheet (title + $ + energy) → save in Firestore.
  Future<void> _editTask(String dateKey, DailyTask task) async {
    final updated = await showModalBottomSheet<BrainDumpEditResult>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => EditTaskSheet(
        initialTitle: task.title,
        showLeverageAndEnergy: true,
        initialValue: task.value,
        initialEnergy: task.energy,
      ),
    );
    if (updated == null || !mounted) return;
    await ref.read(taskActionsProvider.notifier).updateDetails(
          dateKey,
          task,
          title: updated.title,
          energy: updated.energy,
          value: updated.value,
        );
  }

  void _showUndo(String message, VoidCallback? undo) {
    if (!mounted) return;
    final m = ScaffoldMessenger.of(context);
    m.clearSnackBars();
    m.showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      // Sit above the floating input row.
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 80),
      action: undo == null
          ? null
          : SnackBarAction(label: 'UNDO', onPressed: undo),
    ));
  }

  /// Persist a new top-to-bottom order after a drag drop.
  /// [newIndex] is already corrected by onReorderItem (no extra -1).
  void _onReorder(String dateKey, List<DailyTask> tasks, int oldIndex, int newIndex) {
    final reordered = [...tasks];
    final item = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, item);
    ref.read(taskActionsProvider.notifier).reorder(dateKey, reordered);
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(brainDumpDayProvider);
    final dateKey = FirestorePaths.dateKey(day);
    final tasksAsync = ref.watch(dailyTasksProvider(dateKey));

    // When the visible day or habit schedules change, seed Daily Task rows.
    ref.listen(brainDumpDayProvider, (_, next) {
      final defs = ref.read(habitDefinitionsProvider).value;
      if (defs == null) return;
      ref.read(taskActionsProvider.notifier).ensureHabitsForDay(
            FirestorePaths.dateKey(next),
            defs,
          );
    });
    ref.listen(habitDefinitionsProvider, (_, next) {
      next.whenData((defs) {
        ref.read(taskActionsProvider.notifier).ensureHabitsForDay(dateKey, defs);
      });
    });

    // List scrolls under a day bar; floating input pinned above bottom nav.
    return Column(
      children: [
        _PlanningDayBar(day: day),
        Expanded(
          child: Stack(
            children: [
              // SelectionArea wrapped the list for native copy. Commented out
              // because it steals pointer events and blocks drag-to-reorder.
              // Positioned.fill(
              //   child: SelectionArea(child: _buildList(tasksAsync, dateKey)),
              // ),
              Positioned.fill(
                child: _buildList(tasksAsync, dateKey),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _FloatingInputRow(
                  controller: _input,
                  onSubmit: _add,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildList(AsyncValue<List<DailyTask>> tasksAsync, String dateKey) {
    return tasksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('$e', style: const TextStyle(color: Color(0xFFEF9A9A))),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 48, color: Colors.white24),
                SizedBox(height: 12),
                Text('No tasks yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
                SizedBox(height: 6),
                Text(
                  'Type below to add one.\nSwipe right = tomorrow · left = delete',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          );
        }
        return ReorderableListView.builder(
          // Clearance so last items sit above the floating input.
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 88),
          itemCount: tasks.length,
          // Handle-only drag so swipe-to-delete still works on the row.
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) {
            _onReorder(dateKey, tasks, oldIndex, newIndex);
          },
          itemBuilder: (context, i) {
            final task = tasks[i];
            return TaskTile(
              key: ValueKey(task.id),
              task: task,
              onTogglePriority: () {
                HapticFeedback.selectionClick();
                ref.read(taskActionsProvider.notifier).setPriority(
                      dateKey,
                      task,
                      _next(task.priority),
                    );
              },
              onEdit: () => _editTask(dateKey, task),
              onMoveToNextDay: () async {
                HapticFeedback.lightImpact();
                final undo = await ref
                    .read(taskActionsProvider.notifier)
                    .moveToNextDay(dateKey, task);
                _showUndo('Moved to tomorrow', undo);
              },
              onDelete: () {
                HapticFeedback.mediumImpact();
                ref.read(taskActionsProvider.notifier).delete(dateKey, task.id);
                _showUndo(
                  'Task deleted',
                  () => ref
                      .read(taskActionsProvider.notifier)
                      .restore(dateKey, task),
                );
              },
              dragHandle: ReorderableDragStartListener(
                index: i,
                child: const Icon(Icons.drag_handle, color: Colors.white38),
              ),
            );
          },
        );
      },
    );
  }
}

/// Slim bar: day label, chevrons / picker, noon-rollover copy.
class _PlanningDayBar extends ConsumerWidget {
  const _PlanningDayBar({required this.day});

  final DateTime day;

  void _shift(WidgetRef ref, int days) {
    ref.read(brainDumpDayProvider.notifier).setDay(day.add(Duration(days: days)));
  }

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    ref.read(brainDumpDayProvider.notifier).setDay(picked);
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(body, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous day',
            onPressed: () => _shift(ref, -1),
            icon: const Icon(Icons.chevron_left, color: Colors.white70),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _pick(context, ref),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPlanningDate(day),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    planningDaySubtitle(visible: day, now: now),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next day',
            onPressed: () => _shift(ref, 1),
            icon: const Icon(Icons.chevron_right, color: Colors.white70),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            color: const Color(0xFF1E1E1E),
            onSelected: (value) async {
              final dateKey = FirestorePaths.dateKey(day);
              if (value == 'reset') {
                ref.read(brainDumpDayProvider.notifier).resetToDefault();
                return;
              }
              if (value == 'clearThis') {
                final ok = await _confirm(
                  context,
                  'Clear this day’s tasks?',
                  'Deletes every Brain Dump task for ${formatPlanningDate(day)}.',
                );
                if (!ok || !context.mounted) return;
                await ref.read(taskActionsProvider.notifier).deleteAll(dateKey);
                return;
              }
              if (value == 'clearEarlier') {
                final cutoff = FirestorePaths.dateKey(planningDayFor(DateTime.now()));
                final ok = await _confirm(
                  context,
                  'Clear earlier days?',
                  'Deletes Brain Dump lists from before the active noon window.',
                );
                if (!ok || !context.mounted) return;
                await ref.read(taskActionsProvider.notifier).deleteEarlierThan(cutoff);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clearThis', child: Text('Clear this day’s tasks')),
              PopupMenuItem(value: 'clearEarlier', child: Text('Clear earlier days')),
              PopupMenuItem(value: 'reset', child: Text('Back to active day')),
            ],
          ),
        ],
      ),
    );
  }
}

/// Elevated dark input bar anchored above the NavigationBar.
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
                  hintText: 'Add a task…',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
