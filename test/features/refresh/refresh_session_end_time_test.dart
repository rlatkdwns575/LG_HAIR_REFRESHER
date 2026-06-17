import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/utils/session_end_time.dart';

void main() {
  final measureCreatedAt = DateTime.parse('2026-06-15T10:00:00Z');

  group('SessionEndTime.resolveEndTime', () {
    test('uses ended_at when present', () {
      final end = SessionEndTime.resolveEndTime(
        endedAtRaw: '2026-06-15T10:30:00Z',
        startedAtRaw: '2026-06-15T10:00:00Z',
        durationTimeRaw: 300,
      );

      expect(end, DateTime.parse('2026-06-15T10:30:00Z'));
    });

    test('computes from started_at and duration when ended_at missing', () {
      final end = SessionEndTime.resolveEndTime(
        startedAtRaw: '2026-06-15T10:00:00Z',
        durationTimeRaw: 600,
      );

      expect(end, DateTime.parse('2026-06-15T10:10:00Z'));
    });
  });

  group('SessionEndTime.isEndTimeOnOrAfterMeasure', () {
    test('returns true when ended_at is after measure created_at', () {
      expect(
        SessionEndTime.isEndTimeOnOrAfterMeasure(
          measureCreatedAt: measureCreatedAt,
          endedAtRaw: '2026-06-15T10:05:00Z',
        ),
        isTrue,
      );
    });

    test('returns false when ended_at is before measure created_at', () {
      expect(
        SessionEndTime.isEndTimeOnOrAfterMeasure(
          measureCreatedAt: measureCreatedAt,
          endedAtRaw: '2026-06-15T09:30:00Z',
        ),
        isFalse,
      );
    });

    test('uses computed end time when ended_at is missing', () {
      expect(
        SessionEndTime.isEndTimeOnOrAfterMeasure(
          measureCreatedAt: measureCreatedAt,
          startedAtRaw: '2026-06-15T09:50:00Z',
          durationTimeRaw: 900,
        ),
        isTrue,
      );
    });
  });
}
