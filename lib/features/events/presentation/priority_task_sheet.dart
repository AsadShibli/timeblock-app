import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/domain/daily_task.dart';
import '../../tasks/providers/task_providers.dart';

/// Bottom sheet listing Priority Brain Dump tasks for event creation.
class PriorityTaskSheet extends ConsumerWidget {
  const PriorityTaskSheet({super.key, required this.dateKey});

  final String dateKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(priorityTasksProvider(dateKey));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pick a Priority task',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 4),
            const Text(
              'Creates a 1-hour time block',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.45,
              ),
              child: _body(tasksAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(AsyncValue<List<DailyTask>> tasksAsync) {
    return tasksAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Text('$e', style: const TextStyle(color: Color(0xFFEF9A9A))),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No Priority tasks today.\nFlag one in Daily Task first.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const Divider(color: Colors.white12),
          itemBuilder: (context, i) {
            final task = tasks[i];
            return ListTile(
              leading: const Icon(Icons.flag, color: Color(0xFFB39DDB)),
              title: Text(task.title, style: const TextStyle(color: Colors.white)),
              onTap: () => Navigator.of(context).pop(task),
            );
          },
        );
      },
    );
  }
}
