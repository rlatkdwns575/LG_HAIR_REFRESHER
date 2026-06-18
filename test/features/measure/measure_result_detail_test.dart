import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/measure/data/api/measure_result_mapper.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_detail.dart';
import 'package:lg_hair_refresher/features/measure/data/model/measure_result_record.dart';

void main() {
  final actionRecord = MeasureResultRecord(
    measureId: 'mr-action',
    userDeviceId: 'ud-1',
    createdAt: DateTime(2026, 6, 11, 10),
    hairOdorScore: 66,
    hairDustScore: 86,
    totalPollutionScore: 86,
    hairDamageScore: 'Low',
    hairThickness: '가는',
    hairSebum: 'Medium',
    smellType: '땀,음식',
  );

  final stableRecord = MeasureResultRecord(
    measureId: 'mr-stable',
    userDeviceId: 'ud-1',
    createdAt: DateTime(2026, 6, 11, 10),
    hairOdorScore: 20,
    hairDustScore: 25,
    totalPollutionScore: 25,
    hairDamageScore: 'Low',
    hairThickness: '중간',
    hairSebum: 'Low',
  );

  MeasureResult resultFor(MeasureResultRecord record) {
    return MeasureResult(
      odorLevel: MeasureResultMapper.odorLevel(record),
      dustLevel: MeasureResultMapper.dustLevel(record),
      headline: MeasureResult.sample.headline,
      recommendedMode: MeasureResult.sample.recommendedMode,
      sourceRecord: record,
    );
  }

  group('MeasureResultDetail.fromMeasureResult', () {
    test('action-required DB record matches Figma headline values', () {
      final detail = MeasureResultDetail.fromMeasureResult(
        resultFor(actionRecord),
      );

      expect(detail.refreshNeedPercent, 86);
      expect(detail.odorNeedPercent, 66);
      expect(detail.dustNeedPercent, 86);
      expect(detail.hairImpactPercent, 15);
      expect(detail.refreshFocusLabel, '먼지 중심의 집중 리프레시');
      expect(detail.odorSection.title, '냄새 상태');
      expect(detail.odorSection.metrics.last.label, '냄새 유형');
      final perceptionMetric = detail.odorSection.metrics[1];
      expect(perceptionMetric.label, '인지 가능도');
      expect(perceptionMetric.showHelpIcon, isTrue);
      expect(
        perceptionMetric.helpMessage,
        MeasureResultMapper.odorPerceptionHelpMessage,
      );
      expect(detail.dustSection.metrics, hasLength(2));
      expect(detail.hairSection.analysisBadgeLabel, '컨디션 영향 낮음');
      expect(detail.hairSection.metrics, hasLength(4));
      expect(detail.hairSection.metrics[1].label, '모발 손상도');
      expect(detail.hairSection.metrics[2].label, '모발 유분량');
      expect(detail.hairSection.metrics[2].badgeLabel, '보통');
      expect(detail.hairSection.metrics[3].label, '모발 굵기');
    });

    test('stable DB record derives lower refresh need', () {
      final detail = MeasureResultDetail.fromMeasureResult(
        resultFor(stableRecord),
      );

      expect(detail.refreshNeedPercent, lessThan(60));
      expect(detail.exceedsThreshold, isFalse);
      expect(detail.odorSection.analysisBadgeLabel, '케어 필요 낮음');
    });

    test('dust-centric focus when dust score is higher', () {
      final detail = MeasureResultDetail.fromMeasureResult(
        resultFor(actionRecord),
      );

      expect(detail.refreshFocusLabel, contains('먼지'));
    });

    test('throws when sourceRecord is missing', () {
      expect(
        () => MeasureResultDetail.fromMeasureResult(MeasureResult.sample),
        throwsStateError,
      );
    });
  });
}
