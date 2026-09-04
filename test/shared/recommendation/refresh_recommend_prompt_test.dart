import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_basis.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_input.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_prompt.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_schedule_snapshot.dart';

void main() {
  const environment = EnvironmentSnapshot(
    temperatureCelsius: 18.4,
    humidityPercent: 62,
    isRaining: true,
    isSnowing: false,
  );

  group('RefreshRecommendPrompt', () {
    test('message user prompt includes measure json when present', () {
      final context = RefreshRecommendInput(
        basis: RefreshRecommendBasis.measure,
        environment: environment,
        measure: MeasureResultRecord(
          measureId: 'm-1',
          userDeviceId: 'd-1',
          createdAt: DateTime.parse('2026-06-15T10:00:00'),
          hairDustScore: 70,
          hairOdorScore: 65,
          totalPollutionScore: 68,
        ),
      );

      final prompt = RefreshRecommendPrompt.messageUserPrompt(
        context: context,
        recommendedModeName: '외출 후 케어',
      );

      expect(prompt, contains('측정 결과 JSON'));
      expect(prompt, contains('hair_dust_score'));
      expect(prompt, contains('환경 JSON'));
      expect(prompt, contains('외출 후 케어'));
    });

    test('message user prompt includes schedule json when present', () {
      final context = RefreshRecommendInput(
        basis: RefreshRecommendBasis.weatherAndSchedule,
        environment: environment,
        schedule: RefreshRecommendScheduleSnapshot(
          todayEventCount: 1,
          nextEventTitle: '회의',
          todayEvents: [
            RefreshRecommendScheduleEventSnapshot(
              title: '회의',
              eventType: 'importantMeeting',
              timing: 'before',
              startsAt: _scheduleStart,
            ),
          ],
        ),
      );

      final prompt = RefreshRecommendPrompt.messageUserPrompt(
        context: context,
        recommendedModeName: '외출 후 케어',
      );

      expect(prompt, contains('오늘 일정 JSON'));
      expect(prompt, contains('today_event_count'));
      expect(prompt, contains('"events"'));
      expect(prompt, contains('event_type'));
      expect(prompt, contains('외출 후 케어'));
    });
  });
}

final _scheduleStart = DateTime(2026, 6, 17, 14);
