/// Global Wish List item (not tied to a calendar day).
class WishlistItem {
  const WishlistItem({
    required this.id,
    required this.title,
    this.createdAt,
    this.isPriority = false,
  });

  final String id;
  final String title;
  final DateTime? createdAt;
  /// Visual prioritization only — does not sync to the calendar.
  final bool isPriority;

  WishlistItem copyWith({
    String? title,
    bool? isPriority,
  }) {
    return WishlistItem(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      isPriority: isPriority ?? this.isPriority,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'createdAt': createdAt?.toIso8601String(),
        'isPriority': isPriority,
      };

  factory WishlistItem.fromMap(String id, Map<String, dynamic> map) {
    return WishlistItem(
      id: id,
      title: map['title'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? ''),
      isPriority: map['isPriority'] as bool? ?? false,
    );
  }
}
