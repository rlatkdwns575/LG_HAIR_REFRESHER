import '../../../refresh/data/model/refresh_mode.dart';
import '../api/measure_result_mapper.dart';
import 'measure_result.dart';
import 'measure_result_detail_metric.dart';
import 'measure_result_detail_section.dart';

/// 헤어 상태 진단 결과 상세 화면 데이터.
class MeasureResultDetail {
  const MeasureResultDetail({
    required this.refreshNeedPercent,
    required this.recommendedThresholdPercent,
    required this.refreshFocusLabel,
    required this.odorNeedPercent,
    required this.dustNeedPercent,
    required this.hairImpactPercent,
    required this.recommendedMode,
    this.recommendReason,
    required this.odorSection,
    required this.dustSection,
    required this.hairSection,
  });

  final int refreshNeedPercent;
  final int recommendedThresholdPercent;
  final String refreshFocusLabel;
  final int odorNeedPercent;
  final int dustNeedPercent;
  final int hairImpactPercent;
  final RefreshMode recommendedMode;
  final String? recommendReason;
  final MeasureResultDetailSection odorSection;
  final MeasureResultDetailSection dustSection;
  final MeasureResultDetailSection hairSection;

  bool get exceedsThreshold => refreshNeedPercent > recommendedThresholdPercent;

  /// 공유하기(클립보드 복사)용 요약 텍스트.
  String get shareSummaryText =>
      ['내 헤어 상태 진단 결과', '리프레시 필요도 $refreshNeedPercent%'].join('\n');

  factory MeasureResultDetail.fromMeasureResult(MeasureResult result) {
    final record = result.sourceRecord;
    if (record == null) {
      throw StateError(
        'MeasureResultDetail requires MEASURE_RESULTS sourceRecord.',
      );
    }

    final odorScore = record.hairOdorScore;
    final dustScore = record.hairDustScore;
    final odorBadge = MeasureResultMapper.sectionBadge(odorScore);
    final dustBadge = MeasureResultMapper.sectionBadge(dustScore);
    final hairBadge = MeasureResultMapper.hairConditionBadge(record);
    final retentionBadge = MeasureResultMapper.pollutionRetentionBadge(record);
    final sebumBadge = MeasureResultMapper.badgeForHairSebum(record.hairSebum);
    final damageBadge = MeasureResultMapper.badgeForHairLevel(
      record.hairDamageScore,
    );
    final thicknessBadge = MeasureResultMapper.badgeForHairThickness(
      record.hairThickness,
    );
    final odorPerceptionScore = MeasureResultMapper.pollutionScoreStepUp(
      odorScore,
    );

    return MeasureResultDetail(
      refreshNeedPercent: record.totalPollutionScore.clamp(0, 100),
      recommendedThresholdPercent:
          MeasureResultMapper.recommendedThresholdPercent,
      refreshFocusLabel: MeasureResultMapper.focusLabel(record),
      odorNeedPercent: odorScore.clamp(0, 100),
      dustNeedPercent: dustScore.clamp(0, 100),
      hairImpactPercent: MeasureResultMapper.hairImpactPercent(record),
      recommendedMode: result.recommendedMode,
      recommendReason: result.recommendReason,
      odorSection: MeasureResultDetailSection(
        title: '냄새 상태',
        subtitle: '머리카락에 남은 외부 냄새를 분석했어요.',
        analysisBadgeLabel: odorBadge.$1,
        analysisBadgeVariant: odorBadge.$2,
        analysisDescription: MeasureResultMapper.odorAnalysis(odorScore),
        metrics: [
          MeasureResultDetailMetric(
            label: '잔여 냄새 수준',
            badgeLabel: MeasureResultMapper.pollutionScoreLabel(odorScore),
            badgeVariant: MeasureResultMapper.pollutionScoreVariant(odorScore),
          ),
          MeasureResultDetailMetric(
            label: '인지 가능도',
            badgeLabel: MeasureResultMapper.pollutionScoreLabel(
              odorPerceptionScore,
            ),
            badgeVariant: MeasureResultMapper.pollutionScoreVariant(
              odorPerceptionScore,
            ),
            showHelpIcon: true,
            helpMessage: MeasureResultMapper.odorPerceptionHelpMessage,
          ),
          MeasureResultDetailMetric(
            label: '잔류 가능성',
            badgeLabel: MeasureResultMapper.pollutionScoreLabel(odorScore),
            badgeVariant: MeasureResultMapper.pollutionScoreVariant(odorScore),
          ),
          MeasureResultMapper.smellTypeMetric(record),
        ],
      ),
      dustSection: MeasureResultDetailSection(
        title: '먼지 상태',
        subtitle: '머리카락에 남은 외부 먼지의 양과 퍼짐 정도를 분석했어요.',
        analysisBadgeLabel: dustBadge.$1,
        analysisBadgeVariant: dustBadge.$2,
        analysisDescription: MeasureResultMapper.dustAnalysis(dustScore),
        metrics: [
          MeasureResultDetailMetric(
            label: '먼지량',
            badgeLabel: MeasureResultMapper.pollutionScoreLabel(dustScore),
            badgeVariant: MeasureResultMapper.pollutionScoreVariant(dustScore),
          ),
          MeasureResultDetailMetric(
            label: '분포 범위',
            badgeLabel: MeasureResultMapper.pollutionScoreLabel(dustScore),
            badgeVariant: MeasureResultMapper.pollutionScoreVariant(dustScore),
          ),
        ],
      ),
      hairSection: MeasureResultDetailSection(
        title: '모발 상태',
        subtitle: '모발 상태를 바탕으로 잔류 가능성과 리프레시 강도를 조절해요.',
        analysisBadgeLabel: hairBadge.$1,
        analysisBadgeVariant: hairBadge.$2,
        analysisDescription: MeasureResultMapper.hairAnalysis(record),
        metrics: [
          MeasureResultDetailMetric(
            label: '오염 잔류 영향',
            badgeLabel: retentionBadge.$1,
            badgeVariant: retentionBadge.$2,
            showHelpIcon: true,
            helpMessage: MeasureResultMapper.pollutionRetentionHelpMessage,
          ),
          MeasureResultDetailMetric(
            label: '모발 손상도',
            badgeLabel: damageBadge.$1,
            badgeVariant: damageBadge.$2,
          ),
          MeasureResultDetailMetric(
            label: '모발 유분량',
            badgeLabel: sebumBadge.$1,
            badgeVariant: sebumBadge.$2,
          ),
          MeasureResultDetailMetric(
            label: '모발 굵기',
            badgeLabel: thicknessBadge.$1,
            badgeVariant: thicknessBadge.$2,
          ),
        ],
      ),
    );
  }
}
