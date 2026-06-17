import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_basis.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_context_resolver.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_schedule_snapshot.dart';

void main() {
  const environment = EnvironmentSnapshot(
    temperatureCelsius: 18,
    humidityPercent: 60,
    isRaining: false,
    isSnowing: false,
  );

  const scheduleWithEvents = RefreshRecommendScheduleSnapshot(
    todayEventCount: 2,
    nextEventTitle: '저녁 약속',
  );

  const scheduleEmpty = RefreshRecommendScheduleSnapshot(todayEventCount: 0);

  MeasureResultRecord recentRecord({Duration age = Duration.zero}) {
    return MeasureResultRecord(
      measureId: 'm-1',
      userDeviceId: 'd-1',
      createdAt: DateTime(2026, 6, 15, 10).subtract(age),
      hairDustScore: 70,
      hairOdorScore: 65,
      totalPollutionScore: 68,
    );
  }

  final now = DateTime(2026, 6, 15, 10, 30);

  group('RefreshRecommendContextResolver.resolveBasis', () {
    test('uses measure when recent and not refreshed', () {
      expect(
        RefreshRecommendContextResolver.resolveBasis(
          latestMeasure: recentRecord(age: const Duration(minutes: 30)),
          refreshedAfterMeasure: false,
          schedule: scheduleWithEvents,
          now: now,
        ),
        RefreshRecommendBasis.measure,
      );
    });

    test('uses weatherAndSchedule when measure expired', () {
      expect(
        RefreshRecommendContextResolver.resolveBasis(
          latestMeasure: recentRecord(age: const Duration(hours: 3)),
          refreshedAfterMeasure: false,
          schedule: scheduleWithEvents,
          now: now,
        ),
        RefreshRecommendBasis.weatherAndSchedule,
      );
    });

    test('uses weatherAndSchedule when refreshed after measure', () {
      expect(
        RefreshRecommendContextResolver.resolveBasis(
          latestMeasure: recentRecord(age: const Duration(minutes: 30)),
          refreshedAfterMeasure: true,
          schedule: scheduleWithEvents,
          now: now,
        ),
        RefreshRecommendBasis.weatherAndSchedule,
      );
    });

    test('uses weatherOnly when no schedule today', () {
      expect(
        RefreshRecommendContextResolver.resolveBasis(
          latestMeasure: null,
          refreshedAfterMeasure: false,
          schedule: scheduleEmpty,
          now: now,
        ),
        RefreshRecommendBasis.weatherOnly,
      );
    });
  });

  group('RefreshRecommendContextResolver.buildInput', () {
    test('measure basis includes measure json section', () {
      final record = recentRecord();
      final input = RefreshRecommendContextResolver.buildInput(
        basis: RefreshRecommendBasis.measure,
        environment: environment,
        latestMeasure: record,
        schedule: scheduleWithEvents,
      );

      expect(input.includesMeasure, isTrue);
      expect(input.includesSchedule, isTrue);
      expect(input.buildSignature(), contains('measure'));
      expect(input.buildSignature(), contains('m-1'));
    });

    test('weatherOnly basis excludes measure and schedule', () {
      final input = RefreshRecommendContextResolver.buildInput(
        basis: RefreshRecommendBasis.weatherOnly,
        environment: environment,
        latestMeasure: null,
        schedule: scheduleEmpty,
      );

      expect(input.includesMeasure, isFalse);
      expect(input.includesSchedule, isFalse);
    });
  });
}
