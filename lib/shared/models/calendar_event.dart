/// Supabase `CALENDAR_EVENTS` 행.
class CalendarEvent {
  const CalendarEvent({
    required this.eventId,
    required this.userId,
    required this.title,
    required this.eventType,
    required this.startsAt,
    required this.endsAt,
  });

  final String eventId;
  final String userId;
  final String title;
  final String eventType;
  final DateTime startsAt;
  final DateTime endsAt;

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? '',
      eventType: json['event_type'] as String? ?? 'none',
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: DateTime.parse(json['ends_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() => {
    'event_id': eventId,
    'user_id': userId,
    'title': title,
    'event_type': eventType,
    'starts_at': startsAt.toUtc().toIso8601String(),
    'ends_at': endsAt.toUtc().toIso8601String(),
  };

  CalendarEvent copyWith({
    String? eventId,
    String? userId,
    String? title,
    String? eventType,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    return CalendarEvent(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      eventType: eventType ?? this.eventType,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
    );
  }
}
