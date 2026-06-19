import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/api/measure_result_mapper.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_care_level.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_detail.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';

void main() {
  final sampleRecord = MeasureResultRecord(
    measureId: 'mr-1',
    userDeviceId: 'ud-1',
    createdAt: DateTime(2026, 6, 11, 10),
    hairOdorScore: 66,
    hairDustScore: 76,
    totalPollutionScore: 76,
    hairDamageScore: 'Low',
    hairThickness: '가는',
    hairSebum: 'Medium',
    smellType: '땀,음식',
  );

  group('MeasureResultMapper', () {
    test('maps pollution scores to care levels', () {
      expect(
        MeasureResultMapper.odorLevel(sampleRecord),
        MeasureCareLevel.intensiveRecommended,
      );
      expect(
        MeasureResultMapper.dustLevel(sampleRecord),
        MeasureCareLevel.intensiveRecommended,
      );
    });

    test('derives hair impact percent from damage score text', () {
      expect(MeasureResultMapper.hairImpactPercent(sampleRecord), 15);
    });

    test('builds focus label from DB scores', () {
      expect(MeasureResultMapper.focusLabel(sampleRecord), '먼지 중심의 집중 리프레시');
    });

    test('toMeasureResult sets historyCompletedAt from createdAt', () {
      final result = MeasureResultMapper.toMeasureResult(sampleRecord);

      expect(result.historyCompletedAt, sampleRecord.createdAt.toLocal());
    });

    test('maps pollution score labels to five-step scale', () {
      expect(MeasureResultMapper.pollutionScoreLabel(10), '매우낮음');
      expect(MeasureResultMapper.pollutionScoreLabel(35), '낮음');
      expect(MeasureResultMapper.pollutionScoreLabel(55), '보통');
      expect(MeasureResultMapper.pollutionScoreLabel(75), '높음');
      expect(MeasureResultMapper.pollutionScoreLabel(90), '매우높음');
    });

    test('maps hair level and thickness badge labels', () {
      expect(MeasureResultMapper.badgeForHairLevel('Low').$1, '낮음');
      expect(MeasureResultMapper.badgeForHairLevel('Medium').$1, '보통');
      expect(MeasureResultMapper.badgeForHairLevel('High').$1, '높음');
      expect(MeasureResultMapper.badgeForHairThickness('굵은').$1, '굵음');
      expect(MeasureResultMapper.badgeForHairThickness('중간').$1, '보통');
      expect(MeasureResultMapper.badgeForHairThickness('가는').$1, '얇음');
      expect(MeasureResultMapper.badgeForHairSebum('Low').$1, '낮음');
      expect(MeasureResultMapper.badgeForHairSebum('Medium').$1, '보통');
      expect(MeasureResultMapper.badgeForHairSebum('High').$1, '높음');
    });
  });

  group('MeasureResultDetail.fromMeasureResult with record', () {
    test('uses MEASURE_RESULTS scores for summary values', () {
      final result = MeasureResult(
        odorLevel: MeasureCareLevel.intensiveRecommended,
        dustLevel: MeasureCareLevel.intensiveRequired,
        headline: MeasureResult.sample.headline,
        recommendedMode: MeasureResult.sample.recommendedMode,
        sourceRecord: sampleRecord,
      );

      final detail = MeasureResultDetail.fromMeasureResult(result);

      expect(detail.refreshNeedPercent, 76);
      expect(detail.odorNeedPercent, 66);
      expect(detail.dustNeedPercent, 76);
      expect(detail.hairImpactPercent, 15);
      expect(detail.refreshFocusLabel, '먼지 중심의 집중 리프레시');
      expect(detail.hairSection.metrics[0].label, '오염 잔류 영향');
      expect(detail.hairSection.metrics[0].badgeLabel, '낮음');
      expect(detail.hairSection.metrics[1].label, '모발 손상도');
      expect(detail.hairSection.metrics[1].badgeLabel, '낮음');
      expect(detail.hairSection.metrics[2].label, '모발 유분량');
      expect(detail.hairSection.metrics[2].badgeLabel, '보통');
      expect(detail.hairSection.metrics, hasLength(4));
      expect(detail.hairSection.metrics[3].label, '모발 굵기');
      expect(detail.hairSection.metrics[3].badgeLabel, '얇음');
      expect(detail.odorSection.metrics.first.badgeLabel, '높음');
      expect(detail.odorSection.metrics, hasLength(4));
      expect(detail.odorSection.metrics.last.label, '냄새 유형');
      expect(detail.odorSection.metrics.last.tagLabels, ['땀']);
      expect(detail.odorSection.metrics.last.badgeLabel, '음식');
    });

    test('passes historyCompletedAt from measure result', () {
      final completedAt = DateTime(2026, 6, 10, 19, 38);
      final result = MeasureResult(
        odorLevel: MeasureCareLevel.intensiveRecommended,
        dustLevel: MeasureCareLevel.intensiveRequired,
        headline: MeasureResult.sample.headline,
        recommendedMode: MeasureResult.sample.recommendedMode,
        sourceRecord: sampleRecord,
        historyCompletedAt: completedAt,
      );

      final detail = MeasureResultDetail.fromMeasureResult(result);

      expect(detail.historyCompletedAt, completedAt);
    });
  });

  group('MeasureResultMapper smell types', () {
    test('parses comma-separated smell_type text', () {
      expect(MeasureResultMapper.parseSmellTypes('땀,음식'), ['땀', '음식']);
    });
  });

  group('MeasureResultRecord.fromJson', () {
    test('parses actual MEASURE_RESULTS row shape', () {
      final record = MeasureResultRecord.fromJson({
        'measure_id': 'mr-1',
        'user_device_id': 'ud-1',
        'created_at': '2026-06-11T01:00:00.000Z',
        'hair_odor_score': 66,
        'hair_dust_score': 76,
        'total_pollution_score': 76,
        'hair_damage_score': 'Low',
        'hair_thickness': '가는',
        'hair_sebum': 'Medium',
        'smell_type': '땀,음식',
      });

      expect(record.measureId, 'mr-1');
      expect(record.hairOdorScore, 66);
      expect(record.totalPollutionScore, 76);
      expect(record.hairDamageScore, 'Low');
      expect(record.hairThickness, '가는');
      expect(record.hairSebum, 'Medium');
      expect(record.smellType, '땀,음식');
    });
  });
}
