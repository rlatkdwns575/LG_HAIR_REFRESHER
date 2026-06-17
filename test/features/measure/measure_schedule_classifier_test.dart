import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/api/measure_schedule_classifier_api.dart';
import 'package:lg_hair_refresher/features/measure/data/model/schedule_category.dart';
import 'package:lg_hair_refresher/features/measure/data/model/schedule_timing.dart';

void main() {
  const classifier = MeasureScheduleClassifierApi();

  group('MeasureScheduleClassifierApi.classify', () {
    test('maps meeting keywords to importantMeeting', () {
      expect(
        classifier.classifySync(title: '팀 회의'),
        ScheduleCategory.importantMeeting,
      );
    });

    test('maps social keywords to dateOrSocial', () {
      expect(
        classifier.classifySync(title: '저녁 약속'),
        ScheduleCategory.dateOrSocial,
      );
    });

    test('maps cafe keyword to cafeIndoor', () {
      expect(
        classifier.classifySync(title: '카페 미팅'),
        ScheduleCategory.cafeIndoor,
      );
    });

    test('maps meal keywords to meal', () {
      expect(classifier.classifySync(title: '점심 식사'), ScheduleCategory.meal);
    });

    test('maps exercise keywords to exercise', () {
      expect(
        classifier.classifySync(title: '헬스 운동'),
        ScheduleCategory.exercise,
      );
    });

    test('maps commute keywords to commute', () {
      expect(classifier.classifySync(title: '출근'), ScheduleCategory.commute);
    });

    test('returns none for unknown titles', () {
      expect(classifier.classifySync(title: '집안일'), ScheduleCategory.none);
    });
  });

  group('MeasureScheduleClassifierApi.resolveTiming', () {
    final start = DateTime(2026, 6, 17, 18);
    final end = DateTime(2026, 6, 17, 19);

    test('returns before when now is earlier than start', () {
      expect(
        classifier.resolveTimingSync(
          now: DateTime(2026, 6, 17, 17, 30),
          eventStart: start,
          eventEnd: end,
        ),
        ScheduleTiming.before,
      );
    });

    test('returns during when now is within event', () {
      expect(
        classifier.resolveTimingSync(
          now: DateTime(2026, 6, 17, 18, 30),
          eventStart: start,
          eventEnd: end,
        ),
        ScheduleTiming.during,
      );
    });

    test('returns after when now is past end', () {
      expect(
        classifier.resolveTimingSync(
          now: DateTime(2026, 6, 17, 20),
          eventStart: start,
          eventEnd: end,
        ),
        ScheduleTiming.after,
      );
    });
  });
}
