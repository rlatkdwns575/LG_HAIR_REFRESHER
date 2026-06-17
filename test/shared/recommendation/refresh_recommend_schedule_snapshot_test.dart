import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/shared/models/calendar_event.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_schedule_snapshot.dart';

void main() {
  final now = DateTime(2026, 6, 17, 12);

  group('RefreshRecommendScheduleSnapshot.fromCalendarEvents', () {
    test('builds empty snapshot for no events', () {
      final snapshot = RefreshRecommendScheduleSnapshot.fromCalendarEvents(
        const [],
        now,
      );

      expect(snapshot.todayEventCount, 0);
      expect(snapshot.todayEvents, isEmpty);
      expect(snapshot.hasEventsToday, isFalse);
    });

    test('includes events with timing in prompt json', () {
      final events = [
        CalendarEvent(
          eventId: 'e-1',
          userId: 'u-1',
          title: '팀 회의',
          eventType: 'importantMeeting',
          startsAt: DateTime(2026, 6, 17, 14),
          endsAt: DateTime(2026, 6, 17, 15),
        ),
        CalendarEvent(
          eventId: 'e-2',
          userId: 'u-1',
          title: '저녁 약속',
          eventType: 'dateOrSocial',
          startsAt: DateTime(2026, 6, 17, 19),
          endsAt: DateTime(2026, 6, 17, 21),
        ),
      ];

      final snapshot = RefreshRecommendScheduleSnapshot.fromCalendarEvents(
        events,
        now,
      );

      expect(snapshot.todayEventCount, 2);
      expect(snapshot.todayEvents.first.timing, 'before');
      expect(snapshot.nextEvent?.title, '팀 회의');

      final json = snapshot.toPromptJson();
      expect(json['today_event_count'], 2);
      expect(json['events'], hasLength(2));
      expect(json['next_event'], isNotNull);
      expect(json['next_event_title'], '팀 회의');
    });

    test('fingerprint changes when events change', () {
      final first = RefreshRecommendScheduleSnapshot.fromCalendarEvents([
        CalendarEvent(
          eventId: 'e-1',
          userId: 'u-1',
          title: '회의',
          eventType: 'importantMeeting',
          startsAt: DateTime(2026, 6, 17, 14),
          endsAt: DateTime(2026, 6, 17, 15),
        ),
      ], now);
      final second = RefreshRecommendScheduleSnapshot.fromCalendarEvents([
        CalendarEvent(
          eventId: 'e-2',
          userId: 'u-1',
          title: '약속',
          eventType: 'dateOrSocial',
          startsAt: DateTime(2026, 6, 17, 19),
          endsAt: DateTime(2026, 6, 17, 20),
        ),
      ], now);

      expect(first.fingerprint, isNot(second.fingerprint));
    });
  });
}
