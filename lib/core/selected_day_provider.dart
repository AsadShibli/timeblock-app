import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firestore_paths.dart';

part 'selected_day_provider.g.dart';

/// Calendar-midnight "today" for the Execution tab.
/// Brain Dump uses [brainDumpDayProvider] (noon cutoff) instead.
@Riverpod(keepAlive: true)
class SelectedDay extends _$SelectedDay {
  @override
  DateTime build() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  String get dateKey => FirestorePaths.dateKey(state);

  void setDay(DateTime day) {
    state = DateTime(day.year, day.month, day.day);
  }
}
