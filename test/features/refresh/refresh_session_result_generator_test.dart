import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';
import 'package:lg_hair_refresher/features/refresh/data/api/refresh_session_result_generator.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_result_headline_builder.dart';

void main() {
  const generator = RefreshSessionResultGenerator();

  const odorDustMode = RefreshMode(
    id: 'combo',
    name: '복합 케어',
    description: '냄새·먼지',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 180,
    icon: Icons.bolt_outlined,
    odorYn: true,
    dustYn: true,
  );

  const odorOnlyMode = RefreshMode(
    id: 'odor',
    name: '냄새 케어',
    description: '냄새',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 120,
    icon: Icons.bolt_outlined,
    odorYn: true,
  );

  const dustOnlyMode = RefreshMode(
    id: 'dust',
    name: '먼지 케어',
    description: '먼지',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 120,
    icon: Icons.bolt_outlined,
    dustYn: true,
  );

  const scentOnlyMode = RefreshMode(
    id: 'scent',
    name: '향기 케어',
    description: '향기',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 90,
    icon: Icons.local_florist_outlined,
    scentYn: true,
  );

  final baseline = MeasureResultRecord(
    measureId: 'measure-1',
    userDeviceId: 'device-1',
    createdAt: DateTime(2026, 1, 1),
    hairDustScore: 61,
    hairOdorScore: 72,
    totalPollutionScore: 67,
  );

  group('RefreshSessionResultGenerator', () {
    test('uses measure baseline and 30~40% removal with 0.1 steps', () {
      final outcome = generator.generate(
        mode: odorDustMode,
        baseline: baseline,
        random: Random(42),
      );

      expect(outcome.measureId, baseline.measureId);
      expect(outcome.scores.odorBefore, baseline.hairOdorScore);
      expect(outcome.scores.dustBefore, baseline.hairDustScore);

      final odorRemoval = outcome.scores.odorRemovalPercent!;
      final dustRemoval = outcome.scores.dustRemovalPercent!;

      expect(odorRemoval, greaterThanOrEqualTo(30.0));
      expect(odorRemoval, lessThanOrEqualTo(40.0));
      expect(dustRemoval, greaterThanOrEqualTo(30.0));
      expect(dustRemoval, lessThanOrEqualTo(40.0));
      expect(_hasSingleDecimal(odorRemoval), isTrue);
      expect(_hasSingleDecimal(dustRemoval), isTrue);

      expect(
        outcome.scores.odorAfter,
        RefreshSessionResultGenerator.computeAfterScore(
          before: baseline.hairOdorScore,
          removalPercent: odorRemoval,
        ),
      );
      expect(
        outcome.scores.dustAfter,
        RefreshSessionResultGenerator.computeAfterScore(
          before: baseline.hairDustScore,
          removalPercent: dustRemoval,
        ),
      );

      expect(
        outcome.scores.overallImprovementPercent,
        RefreshSessionResultGenerator.computeOverallImprovement(
          odorRemoval: odorRemoval,
          dustRemoval: dustRemoval,
        ),
      );
      expect(
        _hasSingleDecimal(outcome.scores.overallImprovementPercent),
        isTrue,
      );

      expect(outcome.result.odorBeforeScore, outcome.scores.odorBefore);
      expect(outcome.result.dustAfterScore, outcome.scores.dustAfter);
      expect(outcome.scores.pollutionBefore, baseline.hairOdorScore);
      expect(
        outcome.scores.pollutionAfter,
        RefreshSessionResultGenerator.computePollutionScore(
          odor: outcome.scores.odorAfter,
          dust: outcome.scores.dustAfter,
        ),
      );
      expect(outcome.result.headlineBefore, '복합 케어로 남아 있던 냄새와 먼지가');
    });

    test('odor-only mode generates odor scores only', () {
      final outcome = generator.generate(mode: odorOnlyMode, random: Random(7));

      expect(outcome.scores.odorBefore, isNotNull);
      expect(outcome.scores.odorAfter, isNotNull);
      expect(outcome.scores.dustBefore, isNull);
      expect(outcome.scores.dustAfter, isNull);
      expect(outcome.scores.dustRemovalPercent, isNull);
      expect(
        outcome.scores.overallImprovementPercent,
        outcome.scores.odorRemovalPercent,
      );
    });

    test('dust-only mode generates dust scores only', () {
      final outcome = generator.generate(
        mode: dustOnlyMode,
        random: Random(11),
      );

      expect(outcome.scores.dustBefore, isNotNull);
      expect(outcome.scores.dustAfter, isNotNull);
      expect(outcome.scores.odorBefore, isNull);
      expect(outcome.scores.odorAfter, isNull);
    });

    test('scent-only mode stores unchanged pollution score', () {
      final outcome = generator.generate(
        mode: scentOnlyMode,
        baseline: baseline,
      );

      expect(outcome.result.isScentCareResult, isTrue);
      expect(outcome.scores.odorBefore, isNull);
      expect(outcome.scores.dustBefore, isNull);
      expect(outcome.scores.pollutionBefore, baseline.totalPollutionScore);
      expect(outcome.scores.pollutionAfter, baseline.totalPollutionScore);
      expect(outcome.measureId, baseline.measureId);
    });

    test('computePollutionScore uses max of active axes', () {
      expect(
        RefreshSessionResultGenerator.computePollutionScore(odor: 72, dust: 61),
        72,
      );
      expect(
        RefreshSessionResultGenerator.computePollutionScore(odor: 40, dust: 55),
        55,
      );
    });

    test('Monte Carlo keeps removal in 30.0~40.0 with 0.1 precision', () {
      for (var i = 0; i < 200; i++) {
        final outcome = generator.generate(
          mode: odorDustMode,
          random: Random(i),
        );

        for (final removal in [
          outcome.scores.odorRemovalPercent,
          outcome.scores.dustRemovalPercent,
        ]) {
          expect(removal, isNotNull);
          expect(removal!, greaterThanOrEqualTo(30.0));
          expect(removal, lessThanOrEqualTo(40.0));
          expect(_hasSingleDecimal(removal), isTrue);
        }

        final overall = outcome.scores.overallImprovementPercent;
        expect(overall, greaterThanOrEqualTo(30.0));
        expect(overall, lessThanOrEqualTo(40.0));
        expect(_hasSingleDecimal(overall), isTrue);
      }
    });

    test('headline reflects mode category and care type', () {
      const beforeMode = RefreshMode(
        id: 'before',
        name: '외출 전',
        description: '',
        category: RefreshModeTabs.beforeOuting,
        durationSeconds: 120,
        icon: Icons.directions_walk_outlined,
        odorYn: true,
        dustYn: true,
      );
      const weatherMode = RefreshMode(
        id: 'weather',
        name: '날씨',
        description: '',
        category: RefreshModeTabs.weather,
        durationSeconds: 120,
        icon: Icons.wb_sunny_outlined,
        dustYn: true,
      );

      expect(
        RefreshResultHeadlineBuilder.forMode(odorDustMode).before,
        '외출 후 남아 있던 냄새와 먼지가',
      );
      expect(
        RefreshResultHeadlineBuilder.forMode(beforeMode).before,
        '외출 전에 쌓인 냄새와 먼지가',
      );
      expect(
        RefreshResultHeadlineBuilder.forMode(weatherMode).before,
        '날씨에 쌓인 먼지가',
      );
      expect(
        RefreshResultHeadlineBuilder.forMode(odorOnlyMode).before,
        '외출 후 남아 있던 냄새가',
      );
    });

    test('result has no disclaimer on simple view', () {
      final outcome = generator.generate(mode: odorDustMode, random: Random(1));

      expect(outcome.result.disclaimer, isEmpty);
    });

    test('after scores never drop below minimum', () {
      final outcome = generator.generate(
        mode: odorDustMode,
        baseline: MeasureResultRecord(
          measureId: 'm',
          userDeviceId: 'd',
          createdAt: DateTime(2026, 1, 1),
          hairDustScore: 20,
          hairOdorScore: 20,
          totalPollutionScore: 20,
        ),
        random: Random(99),
      );

      expect(outcome.scores.odorAfter!, greaterThanOrEqualTo(18));
      expect(outcome.scores.dustAfter!, greaterThanOrEqualTo(18));
    });
  });
}

bool _hasSingleDecimal(double value) {
  return (value * 10) == (value * 10).roundToDouble();
}
