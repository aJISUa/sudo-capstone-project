enum ScheduleCategory { hospital, exercise, meal, medication, other }

ScheduleCategory _categoryFromString(String s) {
  return ScheduleCategory.values.firstWhere(
    (c) => c.name == s,
    orElse: () => ScheduleCategory.other,
  );
}

/// A user-visible event on today's calendar. Mirrors the React
/// prototype's `ScheduleEvent` shape so a FastAPI build is a drop-in.
class ScheduleEvent {
  const ScheduleEvent({
    required this.id,
    required this.date,
    required this.time,
    required this.title,
    required this.category,
    this.emoji = '',
    this.colorHex = '#E0F2F7',
  });

  final String id;

  /// `YYYY-MM-DD`.
  final String date;

  /// `HH:MM`.
  final String time;
  final String title;
  final ScheduleCategory category;
  final String emoji;
  final String colorHex;

  factory ScheduleEvent.fromJson(Map<String, Object?> json) => ScheduleEvent(
    id: json['id']! as String,
    date: json['date']! as String,
    time: json['time']! as String,
    title: json['title']! as String,
    category: _categoryFromString(json['category']! as String),
    emoji: (json['emoji'] as String?) ?? '',
    colorHex: (json['color_hex'] as String?) ?? '#E0F2F7',
  );
}
