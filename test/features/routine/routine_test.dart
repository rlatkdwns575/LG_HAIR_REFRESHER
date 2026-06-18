import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/routine/data/model/routine.dart';

void main() {
  group('Routine', () {
    test('toJson maps to REFRESH_RECOMMEND_ALARMS columns', () {
      const routine = Routine(
        modeId: 'mode-uuid',
        weekdays: {5, 1, 3},
        hour: 9,
        minute: 5,
      );

      final json = routine.toJson();

      expect(json['mode_id'], 'mode-uuid');
      expect(json['alarm_time'], '09:05:00');
      expect(json['repeat_days'], [1, 3, 5]);
      expect(json['is_enabled'], isTrue);
      expect(json.containsKey('alarm_id'), isFalse);
    });

    test('fromJson parses alarm columns and repeat_days', () {
      final routine = Routine.fromJson({
        'alarm_id': 'abc',
        'mode_id': 'mode-uuid',
        'alarm_time': '07:30:00',
        'repeat_days': [2, 4],
        'is_enabled': false,
      });

      expect(routine.id, 'abc');
      expect(routine.modeId, 'mode-uuid');
      expect(routine.weekdays, {2, 4});
      expect(routine.hour, 7);
      expect(routine.minute, 30);
      expect(routine.enabled, isFalse);
    });

    test('weekdaysLabel renders Korean short labels in order', () {
      const routine = Routine(
        modeId: 'm',
        weekdays: {3, 1},
        hour: 19,
        minute: 0,
      );

      expect(routine.weekdaysLabel, '월·수');
    });
  });

  group('RoutineWeekday.formatTime', () {
    test('formats AM/PM Korean time', () {
      expect(RoutineWeekday.formatTime(6, 0), '오전 6시');
      expect(RoutineWeekday.formatTime(19, 0), '오후 7시');
      expect(RoutineWeekday.formatTime(0, 0), '오전 12시');
      expect(RoutineWeekday.formatTime(12, 30), '오후 12시 30분');
    });
  });
}
