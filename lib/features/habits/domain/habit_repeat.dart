import '../../../core/firestore_paths.dart';

/// How a habit lands on Daily Task days.
enum HabitRepeatKind {
  none,
  daily,
  weekly,
  monthly,
  custom;

  String get firestoreValue => name;

  static HabitRepeatKind fromFirestore(String? value) {
    return HabitRepeatKind.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitRepeatKind.none,
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// True when [day] is inside the habit's saved repeat window.
bool habitAppliesOnDate({
  required HabitRepeatKind kind,
  required DateTime? start,
  required DateTime? end,
  required DateTime day,
}) {
  if (kind == HabitRepeatKind.none || start == null || end == null) return false;
  final d = _dateOnly(day);
  final s = _dateOnly(start);
  final e = _dateOnly(end);
  if (d.isBefore(s) || d.isAfter(e)) return false;
  return switch (kind) {
    HabitRepeatKind.daily || HabitRepeatKind.custom => true,
    HabitRepeatKind.weekly => d.weekday == s.weekday,
    HabitRepeatKind.monthly => d.day == s.day,
    HabitRepeatKind.none => false,
  };
}

/// Dates to seed as Daily Task rows (capped at 90 days from start).
List<DateTime> habitRepeatDates({
  required HabitRepeatKind kind,
  required DateTime start,
  required DateTime end,
}) {
  final s = _dateOnly(start);
  var e = _dateOnly(end);
  final cap = s.add(const Duration(days: 89));
  if (e.isAfter(cap)) e = cap;
  final out = <DateTime>[];
  var d = s;
  while (!d.isAfter(e)) {
    if (habitAppliesOnDate(kind: kind, start: s, end: e, day: d)) {
      out.add(d);
    }
    d = d.add(const Duration(days: 1));
  }
  return out;
}

/// Consecutive completed days; still counts if today is not checked yet.
int habitStreak(Set<String> completedKeys, DateTime now) {
  var cursor = _dateOnly(now);
  if (!completedKeys.contains(FirestorePaths.dateKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var n = 0;
  while (completedKeys.contains(FirestorePaths.dateKey(cursor))) {
    n++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return n;
}
