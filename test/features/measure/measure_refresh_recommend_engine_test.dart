import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/measure_pollution_mapper.dart';
import 'package:lg_hair_refresher/features/measure/data/measure_refresh_recommend_engine.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_care_level.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_refresh_recommend_input.dart';
import 'package:lg_hair_refresher/features/measure/data/model/schedule_category.dart';
import 'package:lg_hair_refresher/features/measure/data/model/schedule_timing.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';

void main() {
  final candidates = [
    RefreshMode(
      id: 'before-1',
      name: '외출 전 케어',
      description: '외출 전',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 300,
      icon: Icons.directions_walk_outlined,
      dustYn: true,
    ),
    RefreshMode(
      id: 'after-1',
      name: '외출 후 케어',
      description: '외출 후',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 480,
      icon: Icons.home_outlined,
      odorYn: true,
      dustYn: true,
      odorStrength: 3,
      dustStrength: 3,
    ),
    RefreshMode(
      id: 'weather-1',
      name: '날씨 케어',
      description: '날씨',
      category: RefreshModeTabs.weather,
      durationSeconds: 360,
      icon: Icons.wb_sunny_outlined,
      dustYn: true,
      dustStrength: 2,
    ),
    RefreshMode(
      id: 'scent-1',
      name: '향기 케어',
      description: '향기',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 120,
      icon: Icons.local_florist_outlined,
      scentYn: true,
    ),
  ];

  MeasureRefreshRecommendInput input({
    double odor = 70,
    double dust = 90,
    double total = 81,
    double temperature = 22,
    int humidity = 50,
    bool precipitating = false,
    ScheduleCategory category = ScheduleCategory.none,
    DateTime? now,
  }) {
    return MeasureRefreshRecommendInput(
      odorPollution: odor,
      dustPollution: dust,
      totalPollution: total,
      temperatureCelsius: temperature,
      humidityPercent: humidity,
      isPrecipitating: precipitating,
      scheduleCategory: category,
      scheduleTiming: ScheduleTiming.none,
      now: now ?? DateTime(2026, 6, 11, 14),
      candidates: candidates,
    );
  }

  group('MeasurePollutionMapper', () {
    test('maps care levels to pollution scores', () {
      final snapshot = MeasurePollutionMapper.fromLevels(
        odorLevel: MeasureCareLevel.intensiveRecommended,
        dustLevel: MeasureCareLevel.intensiveRequired,
      );

      expect(snapshot.odor, 70);
      expect(snapshot.dust, 90);
      expect(snapshot.total, closeTo(81, 0.01));
    });
  });

  group('MeasureRefreshRecommendEngine.recommend', () {
    test(
      'high pollution with precipitation prefers weather or after outing',
      () {
        final result = MeasureRefreshRecommendEngine.recommend(
          input(precipitating: true, humidity: 55),
        );

        expect(result, isNotNull);
        expect(
          ['weather-1', 'after-1'].contains(result!.recommendedMode.id),
          isTrue,
        );
        expect(result.reason, contains('추천해요'));
        expect(result.scores.length, candidates.length);
      },
    );

    test(
      'high pollution with high humidity prefers after outing composite mode',
      () {
        final result = MeasureRefreshRecommendEngine.recommend(
          input(humidity: 75, precipitating: false),
        );

        expect(result?.recommendedMode.id, 'after-1');
        expect(result?.reason, contains('습도'));
      },
    );

    test('low pollution with clear weather prefers before outing mode', () {
      final result = MeasureRefreshRecommendEngine.recommend(
        input(
          odor: 20,
          dust: 20,
          total: 20,
          humidity: 45,
          now: DateTime(2026, 6, 11, 9),
        ),
      );

      expect(result?.recommendedMode.id, 'before-1');
    });

    test(
      'schedule category none does not add social weight to scent-only mode',
      () {
        final result = MeasureRefreshRecommendEngine.recommend(
          input(odor: 20, dust: 20, total: 20, category: ScheduleCategory.none),
        );

        expect(result?.recommendedMode.id, isNot('scent-1'));
      },
    );

    test('meal schedule boosts odor-focused mode', () {
      final result = MeasureRefreshRecommendEngine.recommend(
        input(odor: 40, dust: 30, total: 34.5, category: ScheduleCategory.meal),
      );

      expect(result?.recommendedMode.odorYn, isTrue);
    });

    test('returns null when candidates are empty', () {
      final result = MeasureRefreshRecommendEngine.recommend(
        input().copyWithCandidates(const []),
      );

      expect(result, isNull);
    });
  });
}

extension on MeasureRefreshRecommendInput {
  MeasureRefreshRecommendInput copyWithCandidates(List<RefreshMode> value) {
    return MeasureRefreshRecommendInput(
      odorPollution: odorPollution,
      dustPollution: dustPollution,
      totalPollution: totalPollution,
      temperatureCelsius: temperatureCelsius,
      humidityPercent: humidityPercent,
      isPrecipitating: isPrecipitating,
      scheduleCategory: scheduleCategory,
      scheduleTiming: scheduleTiming,
      now: now,
      candidates: value,
    );
  }
}
