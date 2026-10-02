import 'package:flutter/material.dart';

import '../domain/habit_definition.dart';
import '../domain/habit_repeat.dart';

/// Pick daily / weekly / monthly / custom range; saved days become Daily Tasks.
class HabitRepeatSheet extends StatefulWidget {
  const HabitRepeatSheet({super.key, required this.habit});

  final HabitDefinition habit;

  @override
  State<HabitRepeatSheet> createState() => _HabitRepeatSheetState();
}

class _HabitRepeatSheetState extends State<HabitRepeatSheet> {
  late HabitRepeatKind _kind = widget.habit.repeatKind == HabitRepeatKind.none
      ? HabitRepeatKind.daily
      : widget.habit.repeatKind;
  late DateTime _start = widget.habit.repeatStart ?? DateTime.now();
  late DateTime _end = widget.habit.repeatEnd ??
      DateTime.now().add(const Duration(days: 13));

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() {
      _start = d;
      if (_end.isBefore(_start)) _end = _start;
    });
  }

  Future<void> _pickEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _end.isBefore(_start) ? _start : _end,
      firstDate: _start,
      lastDate: DateTime(2100),
    );
    if (d == null) return;
    setState(() => _end = d);
  }

  Future<void> _pickRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _start, end: _end),
    );
    if (range == null) return;
    setState(() {
      _start = range.start;
      _end = range.end;
    });
  }

  void _save() {
    Navigator.of(context).pop(
      widget.habit.copyWith(repeatKind: _kind, repeatStart: _start, repeatEnd: _end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Repeat on Daily Task',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final k in [
                HabitRepeatKind.daily,
                HabitRepeatKind.weekly,
                HabitRepeatKind.monthly,
                HabitRepeatKind.custom,
              ])
                ChoiceChip(
                  label: Text(k.name),
                  selected: _kind == k,
                  onSelected: (_) => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_kind == HabitRepeatKind.custom)
            FilledButton.tonal(
              onPressed: _pickRange,
              child: Text(
                '${_start.toIso8601String().substring(0, 10)} → '
                '${_end.toIso8601String().substring(0, 10)}',
              ),
            )
          else ...[
            TextButton(onPressed: _pickStart, child: Text('Start ${_start.toIso8601String().substring(0, 10)}')),
            TextButton(onPressed: _pickEnd, child: Text('End ${_end.toIso8601String().substring(0, 10)}')),
          ],
          const SizedBox(height: 8),
          FilledButton(onPressed: _save, child: const Text('Save schedule')),
        ],
      ),
    );
  }
}
