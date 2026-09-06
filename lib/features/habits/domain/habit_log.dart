/// One daily completion log for a habit (dateString = YYYY-MM-DD).
class HabitLog {
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.dateString,
  });

  final String id;
  final String habitId;
  /// Strict calendar day key: YYYY-MM-DD (no timezone reset cron needed).
  final String dateString;

  Map<String, dynamic> toMap() => {
        'habitId': habitId,
        'dateString': dateString,
      };

  factory HabitLog.fromMap(String id, Map<String, dynamic> map) {
    return HabitLog(
      id: id,
      habitId: map['habitId'] as String? ?? '',
      dateString: map['dateString'] as String? ?? '',
    );
  }
}
