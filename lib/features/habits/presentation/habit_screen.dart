import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/presentation/edit_task_sheet.dart';
import '../domain/habit_definition.dart';
import '../domain/habit_row.dart';
import '../providers/habit_providers.dart';
import 'habit_repeat_sheet.dart';
import 'habit_tile.dart';

/// Tab 5: daily Habits — definitions + today's logs (no midnight reset).
class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    await ref.read(habitActionsProvider.notifier).add(text);
    _input.clear();
  }

  /// Title tap → same rename sheet as tasks / wishlist.
  Future<void> _edit(HabitRow row) async {
    final updated = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => EditTaskSheet(
        initialTitle: row.definition.name,
        heading: 'Edit habit',
        fieldLabel: 'Habit',
      ),
    );
    if (updated == null || !mounted) return;
    await ref
        .read(habitActionsProvider.notifier)
        .rename(row.definition.id, updated);
  }

  Future<void> _schedule(HabitRow row) async {
    final updated = await showModalBottomSheet<HabitDefinition>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => HabitRepeatSheet(habit: row.definition),
    );
    if (updated == null || !mounted) return;
    await ref.read(habitActionsProvider.notifier).saveRepeat(updated);
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(todaysHabitsProvider);

    return Stack(
      children: [
        // Phase 2: SelectionArea unlocks native copy/paste on habit text.
        // Input row stays outside so long-press paste on TextField is unblocked.
        Positioned.fill(
          child: SelectionArea(child: _buildList(habitsAsync)),
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

  Widget _buildList(AsyncValue<List<HabitRow>> habitsAsync) {
    return habitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('$e', style: const TextStyle(color: Color(0xFFEF9A9A))),
      ),
      data: (rows) {
        if (rows.isEmpty) {
          return const Center(
            child: Text(
              'No habits yet',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        return Column(
          children: [
            _TodayProgress(rows: rows),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 88),
                itemCount: rows.length,
                itemBuilder: (context, i) {
                  final row = rows[i];
                  return HabitTile(
                    row: row,
                    onToggle: () {
                      ref.read(habitActionsProvider.notifier).toggleToday(row);
                    },
                    onEdit: () => _edit(row),
                    onSchedule: () => _schedule(row),
                    onDelete: () {
                      ref
                          .read(habitActionsProvider.notifier)
                          .deleteDefinition(row.definition.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Circle: completed habits today / total habits (e.g. 1/10).
class _TodayProgress extends StatelessWidget {
  const _TodayProgress({required this.rows});

  final List<HabitRow> rows;

  @override
  Widget build(BuildContext context) {
    final total = rows.length;
    final done = rows.where((r) => r.isCompletedToday).length;
    final value = total == 0 ? 0.0 : done / total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  color: const Color(0xFFB39DDB),
                  backgroundColor: Colors.white12,
                ),
                Text(
                  '$done/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Today’s progress',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

/// Bottom-anchored input (same aesthetic as Brain Dump).
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
                  hintText: 'Add a habit…',
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
