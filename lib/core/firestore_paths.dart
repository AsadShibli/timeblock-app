/// Shared Firestore path helpers.
///
/// Schema:
///   tasks/{userId}/daily_tasks/{yyyy-MM-dd}/items/{taskId}
///   events/{userId}/daily_events/{yyyy-MM-dd}/items/{eventId}
///   wishlist/{userId}/items/{itemId}
///   audit/{userId}/items/{itemId}
///   habits/{userId}/items/{habitId}           // habit definitions
///   habit_logs/{userId}/logs/{logId}          // daily completion logs
class FirestorePaths {
  static String dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String taskItems(String userId, String dateKey) =>
      'tasks/$userId/daily_tasks/$dateKey/items';

  static String eventItems(String userId, String dateKey) =>
      'events/$userId/daily_events/$dateKey/items';

  static String wishlistItems(String userId) => 'wishlist/$userId/items';

  static String auditItems(String userId) => 'audit/$userId/items';

  static String habitItems(String userId) => 'habits/$userId/items';

  static String habitLogs(String userId) => 'habit_logs/$userId/logs';
}
