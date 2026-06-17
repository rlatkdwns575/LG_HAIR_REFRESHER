import '../../features/measure/data/api/measure_schedule_classifier_api.dart';
import '../../shared/models/calendar_event.dart';

/// Gemini 프롬프트용 개별 일정 스냅샷.
class RefreshRecommendScheduleEventSnapshot {
  const RefreshRecommendScheduleEventSnapshot({
    required this.title,
    required this.eventType,
    required this.timing,
    required this.startsAt,
    this.endsAt,
  });

  final String title;
  final String eventType;
  final String timing;
  final DateTime startsAt;
  final DateTime? endsAt;

  Map<String, dynamic> toPromptJson() => {
    'title': title,
    'event_type': eventType,
    'timing': timing,
    'starts_at': startsAt.toIso8601String(),
    if (endsAt != null) 'ends_at': endsAt!.toIso8601String(),
  };
}

/// Gemini 프롬프트용 일정 스냅샷.
class RefreshRecommendScheduleSnapshot {
  const RefreshRecommendScheduleSnapshot({
    required this.todayEventCount,
    this.todayEvents = const [],
    this.nextEvent,
    this.nextEventTitle,
    this.nextEventStartAt,
  });

  final int todayEventCount;
  final List<RefreshRecommendScheduleEventSnapshot> todayEvents;
  final RefreshRecommendScheduleEventSnapshot? nextEvent;
  final String? nextEventTitle;
  final DateTime? nextEventStartAt;

  bool get hasEventsToday => todayEventCount > 0;

  factory RefreshRecommendScheduleSnapshot.fromCalendarEvents(
    List<CalendarEvent> events,
    DateTime now, {
    MeasureScheduleClassifierApi classifier =
        const MeasureScheduleClassifierApi(),
  }) {
    if (events.isEmpty) {
      return const RefreshRecommendScheduleSnapshot(todayEventCount: 0);
    }

    final snapshots = <RefreshRecommendScheduleEventSnapshot>[];
    for (final event in events) {
      final timing = classifier.resolveTimingSync(
        now: now,
        eventStart: event.startsAt,
        eventEnd: event.endsAt,
      );
      snapshots.add(
        RefreshRecommendScheduleEventSnapshot(
          title: event.title,
          eventType: event.eventType,
          timing: timing.name,
          startsAt: event.startsAt,
          endsAt: event.endsAt,
        ),
      );
    }

    RefreshRecommendScheduleEventSnapshot? next;
    for (final snapshot in snapshots) {
      if (!snapshot.startsAt.isBefore(now)) {
        if (next == null || snapshot.startsAt.isBefore(next.startsAt)) {
          next = snapshot;
        }
      }
    }

    return RefreshRecommendScheduleSnapshot(
      todayEventCount: events.length,
      todayEvents: snapshots,
      nextEvent: next,
      nextEventTitle: next?.title,
      nextEventStartAt: next?.startsAt,
    );
  }

  Map<String, dynamic> toPromptJson() => {
    'today_event_count': todayEventCount,
    'events': todayEvents.map((event) => event.toPromptJson()).toList(),
    if (nextEvent != null) 'next_event': nextEvent!.toPromptJson(),
    if (nextEventTitle != null) 'next_event_title': nextEventTitle,
    if (nextEventStartAt != null)
      'next_event_start_at': nextEventStartAt!.toIso8601String(),
  };

  String get fingerprint {
    final eventsPart = todayEvents
        .map(
          (event) =>
              '${event.title}|${event.eventType}|${event.timing}|'
              '${event.startsAt.millisecondsSinceEpoch}',
        )
        .join(';');
    return '$todayEventCount|$eventsPart|'
        '${nextEventStartAt?.millisecondsSinceEpoch ?? 0}';
  }
}
