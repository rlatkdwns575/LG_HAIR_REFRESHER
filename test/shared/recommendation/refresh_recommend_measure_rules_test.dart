import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';
import 'package:lg_hair_refresher/features/refresh/data/api/refresh_recommend_fallback.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_basis.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_input.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_measure_rules.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_schedule_snapshot.dart';

void main() {
  final scentOnly = RefreshMode(
    id: 'scent-only',
    name: '향기 케어',
    description: '향기',
    category: RefreshModeTabs.weather,
    durationSeconds: 300,
    icon: Icons.spa_outlined,
    scentYn: true,
  );

  final odorOnly = RefreshMode(
    id: 'odor-only',
    name: '냄새 케어',
    description: '냄새',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 300,
    icon: Icons.air_outlined,
    odorYn: true,
    scentYn: false,
  );

  final dustOnly = RefreshMode(
    id: 'dust-only',
    name: '먼지 케어',
    description: '먼지',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 300,
    icon: Icons.grain_outlined,
    dustYn: true,
    scentYn: false,
  );

  final bothCare = RefreshMode(
    id: 'both-care',
    name: '외출 후 케어',
    description: '냄새+먼지',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 480,
    icon: Icons.home_outlined,
    odorYn: true,
    dustYn: true,
    scentYn: false,
  );

  final beforeOuting = RefreshMode(
    id: 'before-1',
    name: '외출 전',
    description: '외출 전',
    category: RefreshModeTabs.beforeOuting,
    durationSeconds: 300,
    icon: Icons.directions_walk_outlined,
    odorYn: true,
    dustYn: true,
    scentYn: false,
  );

  final allModes = [scentOnly, odorOnly, dustOnly, bothCare, beforeOuting];

  MeasureResultRecord record({int odor = 70, int dust = 70}) {
    return MeasureResultRecord(
      measureId: 'm-1',
      userDeviceId: 'u-1',
      createdAt: DateTime(2026, 6, 18),
      hairOdorScore: odor,
      hairDustScore: dust,
      totalPollutionScore: odor > dust ? odor : dust,
    );
  }

  group('RefreshRecommendMeasureRules', () {
    test('filterForMeasure keeps odor-only when odor is higher than dust', () {
      final odorFocused = record(odor: 80, dust: 65);
      final filtered = RefreshRecommendMeasureRules.filterForMeasure(
        odorFocused,
        allModes,
      );

      expect(filtered.map((mode) => mode.id), contains(odorOnly.id));
      expect(filtered.map((mode) => mode.id), isNot(contains(dustOnly.id)));
    });

    test(
      'filterForMeasure excludes scent-only and enforces odor/dust flags',
      () {
        final highBoth = record(odor: 80, dust: 80);
        final filtered = RefreshRecommendMeasureRules.filterForMeasure(
          highBoth,
          allModes,
        );

        expect(filtered.every((mode) => !mode.isScentOnlyCare), isTrue);
        expect(filtered.every((mode) => mode.odorYn && mode.dustYn), isTrue);
        expect(filtered.map((mode) => mode.id), contains('both-care'));
        expect(filtered.map((mode) => mode.id), isNot(contains('scent-only')));
      },
    );

    test('filterForMeasure requires odor when only odor score is high', () {
      final odorHigh = record(odor: 75, dust: 30);
      final filtered = RefreshRecommendMeasureRules.filterForMeasure(
        odorHigh,
        allModes,
      );

      expect(filtered.every((mode) => mode.odorYn), isTrue);
      expect(filtered.map((mode) => mode.id), isNot(contains('dust-only')));
    });

    test('pickFromMeasure prefers odor mode when odor is higher', () {
      final odorFocused = record(odor: 80, dust: 65);
      final filtered = RefreshRecommendMeasureRules.filterForMeasure(
        odorFocused,
        allModes,
      );

      final picked = RefreshRecommendMeasureRules.pickFromMeasure(
        odorFocused,
        filtered,
      );

      expect(picked?.odorYn, isTrue);
      expect(picked?.dustYn, isFalse);
      expect(picked?.id, odorOnly.id);
    });

    test('pickFromMeasure prefers dust mode when dust is much higher', () {
      final dustFocused = record(odor: 40, dust: 80);
      final filtered = RefreshRecommendMeasureRules.filterForMeasure(
        dustFocused,
        allModes,
      );

      final picked = RefreshRecommendMeasureRules.pickFromMeasure(
        dustFocused,
        filtered,
      );

      expect(picked?.dustYn, isTrue);
      expect(picked?.odorYn, isFalse);
      expect(picked?.id, dustOnly.id);
    });

    test('pickFromMeasure prefers both when odor and dust are balanced', () {
      final highBoth = record(odor: 80, dust: 80);
      final filtered = RefreshRecommendMeasureRules.filterForMeasure(
        highBoth,
        allModes,
      );

      final picked = RefreshRecommendMeasureRules.pickFromMeasure(
        highBoth,
        filtered,
      );

      expect(picked?.id, bothCare.id);
    });

    test(
      'pickFromMeasure prefers weather category among focused modes when raining',
      () {
        final odorWeather = RefreshMode(
          id: 'odor-weather',
          name: '비 냄새 케어',
          description: '냄새',
          category: RefreshModeTabs.weather,
          durationSeconds: 300,
          icon: Icons.water_drop_outlined,
          odorYn: true,
          scentYn: false,
        );
        final odorFocused = record(odor: 80, dust: 40);
        final picked = RefreshRecommendMeasureRules.pickFromMeasure(
          odorFocused,
          [...allModes, odorWeather],
          environment: const EnvironmentSnapshot(
            temperatureCelsius: 18,
            humidityPercent: 80,
            isRaining: true,
            isSnowing: false,
          ),
        );

        expect(picked?.id, odorWeather.id);
      },
    );

    test(
      'pickFromMeasure prefers beforeOuting when next event is upcoming',
      () {
        final odorBefore = RefreshMode(
          id: 'odor-before',
          name: '외출 전 냄새 케어',
          description: '냄새',
          category: RefreshModeTabs.beforeOuting,
          durationSeconds: 300,
          icon: Icons.directions_walk_outlined,
          odorYn: true,
          scentYn: false,
        );
        final odorFocused = record(odor: 80, dust: 40);
        final picked = RefreshRecommendMeasureRules.pickFromMeasure(
          odorFocused,
          [...allModes, odorBefore],
          environment: const EnvironmentSnapshot(
            temperatureCelsius: 22,
            humidityPercent: 45,
            isRaining: false,
            isSnowing: false,
          ),
          schedule: RefreshRecommendScheduleSnapshot(
            todayEventCount: 1,
            nextEvent: RefreshRecommendScheduleEventSnapshot(
              title: '회의',
              eventType: 'importantMeeting',
              timing: 'before',
              startsAt: DateTime(2026, 6, 18, 19),
            ),
            todayEvents: [
              RefreshRecommendScheduleEventSnapshot(
                title: '회의',
                eventType: 'importantMeeting',
                timing: 'before',
                startsAt: DateTime(2026, 6, 18, 19),
              ),
            ],
          ),
        );

        expect(picked?.id, odorBefore.id);
      },
    );
  });

  group('RefreshRecommendFallback with measure', () {
    test('uses measure rules instead of weather when measure is included', () {
      final highBoth = record(odor: 80, dust: 80);
      final context = RefreshRecommendInput(
        basis: RefreshRecommendBasis.measure,
        environment: const EnvironmentSnapshot(
          temperatureCelsius: 18,
          humidityPercent: 50,
          isRaining: true,
          isSnowing: false,
        ),
        measure: highBoth,
      );

      final mode = RefreshRecommendFallback.pickMode(
        candidates: allModes,
        context: context,
      );

      expect(mode?.id, bothCare.id);
    });
  });
}
