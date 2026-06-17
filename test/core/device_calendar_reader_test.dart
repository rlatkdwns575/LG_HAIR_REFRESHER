import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/utils/calendar_day_range.dart';

void main() {
  group('today event overlap', () {
    final range = CalendarDayRange.forDate(DateTime(2026, 6, 17, 15));

    bool overlaps(DateTime start, DateTime end) {
      return end.isAfter(range.start) && start.isBefore(range.end);
    }

    test('includes timed event starting today', () {
      expect(
        overlaps(DateTime(2026, 6, 17, 19), DateTime(2026, 6, 17, 20)),
        isTrue,
      );
    });

    test('includes all-day event covering today', () {
      expect(overlaps(DateTime(2026, 6, 17), DateTime(2026, 6, 18)), isTrue);
    });

    test('includes event started yesterday and ending today', () {
      expect(
        overlaps(DateTime(2026, 6, 16, 22), DateTime(2026, 6, 17, 2)),
        isTrue,
      );
    });

    test('includes 7pm timed event on same day', () {
      expect(
        overlaps(DateTime(2026, 6, 17, 19), DateTime(2026, 6, 17, 21)),
        isTrue,
      );
    });

    test('excludes event entirely tomorrow', () {
      expect(
        overlaps(DateTime(2026, 6, 18, 10), DateTime(2026, 6, 18, 11)),
        isFalse,
      );
    });
  });
}
