import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kalender/kalender.dart';

import '../../../core/firestore_paths.dart';
import '../../../core/selected_day_provider.dart';
import '../../tasks/domain/daily_task.dart';
import '../domain/daily_event.dart';
import '../domain/event_color.dart';
import '../domain/kalender_block.dart';
import '../providers/event_providers.dart';
import 'edit_event_sheet.dart';
import 'event_block_tile.dart';
import 'priority_task_sheet.dart';

/// Tab 2: day calendar — web drag/resize, cursors, Google-style time ruler.
class ExecutionCalendarScreen extends ConsumerStatefulWidget {
  const ExecutionCalendarScreen({super.key});

  @override
  ConsumerState<ExecutionCalendarScreen> createState() =>
      _ExecutionCalendarScreenState();
}

class _ExecutionCalendarScreenState
    extends ConsumerState<ExecutionCalendarScreen> {
  final _eventsController = DefaultEventsController();
  final _calendarController = CalendarController();
  String? _lastSyncSignature;
  /// True while a drag/resize is in progress (skip Firestore→UI replace).
  bool _isDragging = false;

  late final _view = MultiDayViewConfiguration.singleDay(
    initialHeightPerMinute: 1.0,
    initialTimeOfDay: const TimeOfDay(hour: 7, minute: 0),
  );

  // Tap-drag to move/resize on all platforms so long-press can delete (iOS PWA).
  late final _interaction = CalendarInteraction(
    allowResizing: true,
    allowRescheduling: true,
    allowEventCreation: true,
    inputMode: kIsWeb ? InputMode.precise : InputMode.imprecise,
    createEventGesture: CreateEventGesture.longPress,
    modifyEventGesture: CreateEventGesture.tap,
  );

  static const _snapping = CalendarSnapping(snapIntervalMinutes: 15);

  @override
  void dispose() {
    _calendarController.dispose();
    _eventsController.dispose();
    super.dispose();
  }

  String get _dateKey =>
      FirestorePaths.dateKey(ref.read(selectedDayProvider));

  /// Google Calendar labels: "7 AM" — hide mid-hour text (grid lines stay).
  static String _googleHourLabel(BuildContext context, TimeOfDay time) {
    if (time.minute != 0) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final suffix = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour $suffix';
  }

  void _syncFromFirestore(List<DailyEvent> events) {
    if (_isDragging) return; // don't fight an active drag/resize
    final signature = events
        .map((e) => '${e.id}:${e.start}:${e.end}:${e.title}:${e.description}')
        .join('|');
    if (signature == _lastSyncSignature) return;
    _lastSyncSignature = signature;
    _eventsController.replaceEvents(
      events.map(KalenderBlock.fromDaily).toList(),
    );
  }

  DateTime _snap15(DateTime raw) {
    final local = raw.toLocal();
    final minute = (local.minute ~/ 15) * 15;
    return DateTime(local.year, local.month, local.day, local.hour, minute);
  }

  Future<void> _createFromPriority(DateTime at) async {
    final start = _snap15(at);
    final task = await showModalBottomSheet<DailyTask>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      isScrollControlled: true,
      builder: (context) => PriorityTaskSheet(dateKey: _dateKey),
    );
    if (task == null || !mounted) return;

    await ref.read(eventActionsProvider.notifier).add(
          _dateKey,
          DailyEvent(
            id: '',
            title: task.title,
            description: 'From Daily Task',
            start: start,
            end: start.add(const Duration(hours: 1)),
            color: EventColor.byIndex(_eventsController.events.length),
            sourceTaskId: task.id,
          ),
        );
  }

  Future<void> _onEventTapped(CalendarEvent event) async {
    final block = event as KalenderBlock;
    final result = await showModalBottomSheet<EditEventResult>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      // Phase 1: allow sheet to grow with content + keyboard (not 50% clamp).
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => EditEventSheet(block: block),
    );
    if (result == null || !mounted) return;

    // Phase 1: modal Delete → Firestore delete + optimistic UI remove.
    if (result.isDelete) {
      await _deleteEvent(result.deleteId!);
      return;
    }

    final updated = result.block!;
    _eventsController.updateEvent(event: block, updatedEvent: updated);
    _lastSyncSignature = null;
    await ref
        .read(eventActionsProvider.notifier)
        .update(_dateKey, updated.toDaily());
  }

  /// Shared delete path (modal + long-press). Optimistic remove + Firestore.
  Future<void> _deleteEvent(String eventId) async {
    _eventsController.removeById(eventId);
    _lastSyncSignature = null;
    await ref.read(eventActionsProvider.notifier).delete(_dateKey, eventId);
  }

  /// Phase 2: long-press → Cupertino confirm → same delete as modal.
  Future<void> _confirmDelete(KalenderBlock block) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete this focus block?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _deleteEvent(block.id);
  }

  /// Drag/resize start (kalender onEventChange).
  void _onDragStart(CalendarEvent event) {
    _isDragging = true;
  }

  /// Drag/resize end → persist new start/end to Firestore immediately.
  Future<void> _onDragEnd(CalendarEvent before, CalendarEvent after) async {
    _isDragging = false;
    final block = after as KalenderBlock;
    await ref
        .read(eventActionsProvider.notifier)
        .update(_dateKey, block.toDaily());
  }

  @override
  Widget build(BuildContext context) {
    final dateKey = FirestorePaths.dateKey(ref.watch(selectedDayProvider));

    ref.listen(
      dailyEventsProvider(dateKey),
      (prev, next) => next.whenData(_syncFromFirestore),
    );
    final snap = ref.watch(dailyEventsProvider(dateKey));
    if (snap.hasValue) {
      final events = snap.requireValue;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncFromFirestore(events);
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createFromPriority(DateTime.now()),
        backgroundColor: const Color(0xFFB39DDB),
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
      body: CalendarView(
        eventsController: _eventsController,
        calendarController: _calendarController,
        viewConfiguration: _view,
        // Google-style hour labels via timelineStringBuilder.
        components: CalendarComponents(
          multiDayComponents: MultiDayComponents(
            bodyComponents: MultiDayBodyComponents(
              timelineStringBuilder: _googleHourLabel,
            ),
          ),
        ),
        callbacks: CalendarCallbacks(
          onTapped: _createFromPriority,
          onEventTapped: (event, renderBox) => _onEventTapped(event),
          onEventCreate: (event) => null,
          onEventChange: _onDragStart,
          onEventChanged: _onDragEnd,
        ),
        header: const CalendarHeader(),
        body: CalendarBody(
          interaction: _interaction,
          snapping: _snapping,
          multiDayTileComponents: TileComponents(
            tileBuilder: _tile,
            // Feedback while dragging (web mouse drag).
            tileWhenDraggingBuilder: (event) =>
                Opacity(opacity: 0.4, child: _tile(event, event.dateTimeRange)),
            feedbackTileBuilder: (event, size) => Material(
              color: Colors.transparent,
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: _tile(event, event.dateTimeRange),
              ),
            ),
            // Explicit resize handle with up/down cursor for web.
            verticalResizeHandle: MouseRegion(
              cursor: SystemMouseCursors.resizeUpDown,
              child: Container(
                height: 10,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(CalendarEvent event, DateTimeRange tileRange) {
    final block = event as KalenderBlock;
    return EventBlockTile(
      block: block,
      onLongPressDelete: () => _confirmDelete(block),
    );
  }
}
