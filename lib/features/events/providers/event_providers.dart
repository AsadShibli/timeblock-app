import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/event_repository.dart';
import '../domain/daily_event.dart';

part 'event_providers.g.dart';

@Riverpod(keepAlive: true)
EventRepository eventRepository(Ref ref) => EventRepository();

/// Real-time time blocks for a day. [dateKey] format: yyyy-MM-dd.
@riverpod
Stream<List<DailyEvent>> dailyEvents(Ref ref, String dateKey) {
  final uid = ref.watch(authSessionProvider);
  if (uid == null) return Stream.value(const []);
  return ref.watch(eventRepositoryProvider).watchDailyEvents(uid, dateKey);
}

/// Write helpers for calendar events (create / move-resize / delete).
@riverpod
class EventActions extends _$EventActions {
  @override
  void build() {}

  String? get _uid => ref.read(authSessionProvider);
  EventRepository get _repo => ref.read(eventRepositoryProvider);

  Future<void> add(String dateKey, DailyEvent event) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.addEvent(uid, dateKey, event);
  }

  Future<void> update(String dateKey, DailyEvent event) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.updateEvent(uid, dateKey, event);
  }

  Future<void> delete(String dateKey, String eventId) async {
    final uid = _uid;
    if (uid == null) return;
    await _repo.deleteEvent(uid, dateKey, eventId);
  }
}
