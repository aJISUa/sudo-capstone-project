enum AlertCategory { reminder, healthCheck, achievement, system }

class AlertItem {
  const AlertItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.category,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final AlertCategory category;
  final bool read;

  AlertItem copyWith({bool? read}) => AlertItem(
    id: id,
    title: title,
    body: body,
    timeAgo: timeAgo,
    category: category,
    read: read ?? this.read,
  );
}

class NotificationState {
  const NotificationState({required this.items});
  final List<AlertItem> items;
  int get unreadCount => items.where((AlertItem i) => !i.read).length;
}
