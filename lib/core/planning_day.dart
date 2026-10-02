// Brain Dump "planning day" helpers. Execution still uses calendar midnight.
//
// Before local 12:00, yesterday stays on screen so a late-night list
// does not vanish at midnight. At noon it flips to today.

/// Calendar date Brain Dump should show for [now] when the user has not picked a day.
DateTime planningDayFor(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  // Hour 0–11: keep yesterday until noon.
  if (now.hour < 12) {
    return today.subtract(const Duration(days: 1));
  }
  return today;
}

/// Next local noon after [now], used to auto-flip an unpinned overnight session.
DateTime nextNoonAfter(DateTime now) {
  final todaysNoon = DateTime(now.year, now.month, now.day, 12);
  if (now.isBefore(todaysNoon)) return todaysNoon;
  return todaysNoon.add(const Duration(days: 1));
}

/// How the visible Brain Dump day relates to the noon-based default.
enum PlanningDayKind { active, planningAhead, earlier }

PlanningDayKind planningDayKind({
  required DateTime visible,
  required DateTime now,
}) {
  final def = planningDayFor(now);
  final v = DateTime(visible.year, visible.month, visible.day);
  if (v.isAfter(def)) return PlanningDayKind.planningAhead;
  if (v.isBefore(def)) return PlanningDayKind.earlier;
  return PlanningDayKind.active;
}

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// e.g. "Tue 8 Sep"
String formatPlanningDate(DateTime day) {
  return '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';
}

/// Context line under the date: until noon, planning ahead, or earlier day.
String planningDaySubtitle({
  required DateTime visible,
  required DateTime now,
}) {
  switch (planningDayKind(visible: visible, now: now)) {
    case PlanningDayKind.planningAhead:
      return 'Planning ahead for ${formatPlanningDate(visible)}';
    case PlanningDayKind.earlier:
      return 'Earlier day';
    case PlanningDayKind.active:
      if (now.hour < 12) {
        return 'Still ${_weekdays[visible.weekday - 1]} until 12:00';
      }
      return 'Until tomorrow 12:00';
  }
}
