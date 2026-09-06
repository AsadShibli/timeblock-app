import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/selected_day_provider.dart';
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
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String get _dateKey =>
      FirestorePaths.dateKey(ref.read(selectedDayProvider));

  Future<void> _add() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    await ref.read(taskActionsProvider.notifier).add(_dateKey, text);
    _input.clear();
  }

  /// unlabeled -> priority -> nonPriority -> unlabeled
  TaskPriority _next(TaskPriority current) => switch (current) {
        TaskPriority.unlabeled => TaskPriority.priority,
        TaskPriority.priority => TaskPriority.nonPriority,
        TaskPriority.nonPriority => TaskPriority.unlabeled,
      };

  /// Phase 3: title tap → autofocus edit sheet → rename in Firestore.
  Future<void> _editTask(String dateKey, DailyTask task) async {
    final updated = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => EditTaskSheet(initialTitle: task.title),
    );
    if (updated == null || !mounted) return;
    await ref.read(taskActionsProvider.notifier).rename(dateKey, task, updated);
  }

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(selectedDayProvider);
    final dateKey = FirestorePaths.dateKey(day);
    final tasksAsync = ref.watch(dailyTasksProvider(dateKey));

    // List scrolls full-bleed; floating input pinned above bottom nav.
    return Stack(
      children: [
        // Native highlight/copy for task titles (SelectionArea).
        Positioned.fill(
          child: SelectionArea(child: _buildList(tasksAsync, dateKey)),
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
            child: Text('No tasks yet', style: TextStyle(color: Colors.white38)),
          );
        }
        return ListView.builder(
          // Clearance so last items sit above the floating input.
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 88),
          itemCount: tasks.length,
          itemBuilder: (context, i) {
            final task = tasks[i];
            return TaskTile(
              task: task,
              onTogglePriority: () {
                ref.read(taskActionsProvider.notifier).setPriority(
                      dateKey,
                      task,
                      _next(task.priority),
                    );
              },
              onEdit: () => _editTask(dateKey, task),
              onDelete: () {
                ref.read(taskActionsProvider.notifier).delete(dateKey, task.id);
              },
            );
          },
        );
      },
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
