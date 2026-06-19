import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/utils/notification_schedule_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz_data.initializeTimeZones();
  final location = tz.getLocation('Asia/Seoul');

  group('nextZonedNotificationTime', () {
    test('returns later today when weekday and time match', () {
      // 2026-06-18 is Thursday (weekday=4)
      final now = tz.TZDateTime(location, 2026, 6, 18, 10, 0);
      final next = nextZonedNotificationTime(
        location: location,
        weekday: 4,
        hour: 19,
        minute: 30,
        now: now,
      );

      expect(next, tz.TZDateTime(location, 2026, 6, 18, 19, 30));
    });

    test('returns next week when today time already passed', () {
      final now = tz.TZDateTime(location, 2026, 6, 18, 20, 0);
      final next = nextZonedNotificationTime(
        location: location,
        weekday: 4,
        hour: 19,
        minute: 0,
        now: now,
      );

      expect(next, tz.TZDateTime(location, 2026, 6, 25, 19, 0));
    });

    test('returns next matching weekday in the future', () {
      // Thursday -> next Friday
      final now = tz.TZDateTime(location, 2026, 6, 18, 10, 0);
      final next = nextZonedNotificationTime(
        location: location,
        weekday: 5,
        hour: 8,
        minute: 0,
        now: now,
      );

      expect(next, tz.TZDateTime(location, 2026, 6, 19, 8, 0));
    });
  });
}
