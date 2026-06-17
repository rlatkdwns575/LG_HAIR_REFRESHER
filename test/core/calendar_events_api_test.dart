import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/utils/calendar_day_range.dart';
import 'package:lg_hair_refresher/core/utils/stable_calendar_event_id.dart';
import 'package:lg_hair_refresher/shared/models/calendar_event.dart';

void main() {
  group('CalendarDayRange', () {
    test('forDate returns local midnight to next midnight', () {
      final range = CalendarDayRange.forDate(DateTime(2026, 6, 17, 15, 30));
      expect(range.start, DateTime(2026, 6, 17));
      expect(range.end, DateTime(2026, 6, 18));
    });
  });

  group('stableCalendarEventId', () {
    test('generates stable uuid-like ids', () {
      final first = stableCalendarEventId(
        userId: 'user-1',
        deviceEventId: 'device-1',
        startsAt: DateTime(2026, 6, 17, 19),
      );
      final second = stableCalendarEventId(
        userId: 'user-1',
        deviceEventId: 'device-1',
        startsAt: DateTime(2026, 6, 17, 19),
      );
      final different = stableCalendarEventId(
        userId: 'user-1',
        deviceEventId: 'device-2',
        startsAt: DateTime(2026, 6, 17, 19),
      );

      expect(first, second);
      expect(first, isNot(different));
      expect(
        first,
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          ),
        ),
      );
    });
  });

  group('CalendarEvent', () {
    test('serializes insert payload in utc', () {
      final event = CalendarEvent(
        eventId: 'id-1',
        userId: 'user-1',
        title: '회의',
        eventType: 'importantMeeting',
        startsAt: DateTime(2026, 6, 17, 10),
        endsAt: DateTime(2026, 6, 17, 11),
      );

      final json = event.toInsertJson();
      expect(json['title'], '회의');
      expect(json['event_type'], 'importantMeeting');
      expect(json['starts_at'], isA<String>());
    });
  });
}
