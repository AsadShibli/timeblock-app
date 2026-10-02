import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firestore_paths.dart';
import 'planning_day.dart';

part 'brain_dump_day_provider.g.dart';

/// Brain Dump visible day. Defaults to [planningDayFor]; Execution is unchanged.
@Riverpod(keepAlive: true)
class BrainDumpDay extends _$BrainDumpDay {
  /// True after the user picks a day; noon auto-flip is skipped until reset.
  bool _pinned = false;
  DateTime? _pinnedDay;
  Timer? _noonTimer;

  @override
  DateTime build() {
    ref.onDispose(() => _noonTimer?.cancel());
    _scheduleNoonFlip();
    // Keep a user-picked day if Riverpod re-runs build().
    return _pinnedDay ?? planningDayFor(DateTime.now());
  }

  String get dateKey => FirestorePaths.dateKey(state);

  /// Pin to a specific calendar day (night-ahead planning or browsing old lists).
  void setDay(DateTime day) {
    _pinned = true;
    _pinnedDay = DateTime(day.year, day.month, day.day);
    state = _pinnedDay!;
  }

  /// Go back to the noon-based default window.
  void resetToDefault() {
    _pinned = false;
    _pinnedDay = null;
    state = planningDayFor(DateTime.now());
  }

  void _scheduleNoonFlip() {
    _noonTimer?.cancel();
    final now = DateTime.now();
    final delay = nextNoonAfter(now).difference(now);
    _noonTimer = Timer(delay, () {
      if (!_pinned) {
        state = planningDayFor(DateTime.now());
      }
      _scheduleNoonFlip();
    });
  }
}
