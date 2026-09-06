import 'package:flutter/material.dart';

import '../domain/kalender_block.dart';

/// Result from [EditEventSheet]: save updates, or request deletion by id.
class EditEventResult {
  const EditEventResult.save(this.block) : deleteId = null;
  const EditEventResult.delete(this.deleteId) : block = null;

  final KalenderBlock? block;
  final String? deleteId;
  bool get isDelete => deleteId != null;
}

/// Dark edit sheet: title, expandable description, start/end, Save / Delete.
class EditEventSheet extends StatefulWidget {
  const EditEventSheet({super.key, required this.block});

  final KalenderBlock block;

  @override
  State<EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<EditEventSheet> {
  late final _title = TextEditingController(text: widget.block.title);
  late final _desc = TextEditingController(text: widget.block.description ?? '');
  late DateTime _start = widget.block.start.toLocal();
  late DateTime _end = widget.block.end.toLocal();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  String _fmt(DateTime dt) {
    final tod = TimeOfDay.fromDateTime(dt);
    final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final m = tod.minute.toString().padLeft(2, '0');
    final suffix = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $suffix';
  }

  DateTime _onSameDay(TimeOfDay tod) =>
      DateTime(_start.year, _start.month, _start.day, tod.hour, tod.minute);

  void _ensureValidDuration() {
    final minEnd = _start.add(const Duration(minutes: 15));
    if (!_end.isAfter(_start) || _end.isBefore(minEnd)) {
      _end = minEnd;
    }
  }

  Future<void> _pickStart() async {
    var currentDuration = _end.difference(_start);
    if (currentDuration <= Duration.zero) {
      currentDuration = const Duration(hours: 1);
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _start = _onSameDay(picked);
      _end = _start.add(currentDuration);
    });
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _end = _onSameDay(picked);
      _ensureValidDuration();
    });
  }

  void _save() {
    _ensureValidDuration();
    Navigator.of(context).pop(
      EditEventResult.save(
        widget.block.copyWith(
          title: _title.text.trim(),
          description: _desc.text.trim(),
          dateTimeRange: DateTimeRange(start: _start, end: _end),
        ),
      ),
    );
  }

  void _delete() {
    Navigator.of(context).pop(EditEventResult.delete(widget.block.id));
  }

  @override
  Widget build(BuildContext context) {
    // Phase 1: no fixed 50%/55% clamp — keyboard-aware scrollable canvas.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit block',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: _delete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF9A9A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _title,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Phase 2: large multiline description.
              TextField(
                controller: _desc,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                minLines: 4,
                maxLines: 8,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white54),
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ActionChip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text('Start  ${_fmt(_start)}'),
                      onPressed: _pickStart,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActionChip(
                      avatar: const Icon(Icons.schedule, size: 18),
                      label: Text('End  ${_fmt(_end)}'),
                      onPressed: _pickEnd,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF9A9A),
                        side: const BorderSide(color: Color(0xFFEF9A9A)),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
