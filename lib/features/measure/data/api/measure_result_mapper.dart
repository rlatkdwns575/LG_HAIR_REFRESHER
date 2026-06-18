import '../../../../shared/utils/metric_badge_mapper.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../history/data/api/history_session_mapper.dart';
import '../../../history/data/model/care_status.dart';
import '../model/measure_care_level.dart';
import '../model/measure_result.dart';
import '../model/measure_result_detail_metric.dart';
import '../model/measure_result_record.dart';

/// `MEASURE_RESULTS` 행 → 케어 레벨·배지 변환.
class MeasureResultMapper {
  const MeasureResultMapper._();

  static const recommendedThresholdPercent = 60;

  static const pollutionRetentionHelpMessage =
      '손상도, 유분량, 수분감을 바탕으로\n'
      '냄새와 먼지가 모발에 얼마나 오래 남기\n'
      '쉬운지 분석한 값이에요.';

  static const refreshNeedHelpMessage =
      '냄새, 먼지, 모발 컨디션을 종합해 리프레시가\n'
      '얼마나 필요한지 보여줘요. 60% 이상이면\n'
      '케어 권장 구간으로 표시돼요.';

  static const odorPerceptionHelpMessage =
      '가까운 거리에서 잔여 냄새나 외부 흔적이\n'
      '느껴질 가능성을 나타내요. 대면 전 케어\n'
      '필요성을 판단하는 데 활용돼요.';

  /// 저장된 측정 데이터를 진단 상세 화면용 [MeasureResult]로 변환합니다.
  ///
  /// 기록(히스토리)에서 과거 진단 결과를 다시 열 때 사용합니다.
  static MeasureResult toMeasureResult(MeasureResultRecord record) {
    final odor = odorLevel(record);
    final dust = dustLevel(record);
    final needsAction = odor.needsAction || dust.needsAction;
    final template = needsAction
        ? MeasureResult.sampleActionRequired
        : MeasureResult.sampleStable;

    return MeasureResult(
      odorLevel: odor,
      dustLevel: dust,
      headline: template.headline,
      recommendedMode: template.recommendedMode,
      recommendReason: template.recommendReason,
      sourceRecord: record,
    );
  }

  static MeasureCareLevel odorLevel(MeasureResultRecord record) {
    return careLevelFromPollutionScore(record.hairOdorScore);
  }

  static MeasureCareLevel dustLevel(MeasureResultRecord record) {
    return careLevelFromPollutionScore(record.hairDustScore);
  }

  static MeasureCareLevel careLevelFromPollutionScore(int score) {
    final status = HistorySessionMapper.fromPollutionScore(score);
    if (status == null) {
      return MeasureCareLevel.normal;
    }
    return switch (status) {
      CareStatus.notNeeded || CareStatus.good => MeasureCareLevel.notRequired,
      CareStatus.normal => MeasureCareLevel.normal,
      CareStatus.recommend => MeasureCareLevel.recommended,
      CareStatus.focusedRecommend => MeasureCareLevel.intensiveRecommended,
      CareStatus.focusedRequired => MeasureCareLevel.intensiveRequired,
    };
  }

  static int hairImpactPercent(MeasureResultRecord record) {
    final damage = record.hairDamageScore?.trim().toLowerCase() ?? '';
    return switch (damage) {
      'low' || '낮음' => 15,
      'medium' || '보통' || '중간' => 30,
      'high' || '높음' => 45,
      _ => (record.totalPollutionScore * 0.3).round().clamp(0, 100),
    };
  }

  static String pollutionScoreLabel(int score) =>
      MetricBadgeMapper.pollutionScoreLabel(score);

  static AppBadgeSmallVariant pollutionScoreVariant(int score) =>
      MetricBadgeMapper.pollutionScoreVariant(score);

  static int pollutionScoreStepUp(int score) =>
      MetricBadgeMapper.pollutionScoreStepUp(score);

  static String focusLabel(MeasureResultRecord record) {
    if (record.hairDustScore > record.hairOdorScore + 5) {
      return '먼지 중심의 집중 리프레시';
    }
    if (record.hairOdorScore > record.hairDustScore + 5) {
      return '냄새 중심의 집중 리프레시';
    }
    return '균형 잡힌 리프레시';
  }

  static (String label, AppBadgeSmallVariant variant) badgeForHairLevel(
    String? raw, {
    String fallbackLabel = '-',
  }) => MetricBadgeMapper.badgeForHairLevel(raw, fallbackLabel: fallbackLabel);

  static (String label, AppBadgeSmallVariant variant) badgeForHairSebum(
    String? raw, {
    String fallbackLabel = '-',
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return (fallbackLabel, AppBadgeSmallVariant.gray);
    }

    final normalized = raw.trim();
    final lower = normalized.toLowerCase();

    return switch (lower) {
      'low' || '낮음' || '적음' => ('낮음', AppBadgeSmallVariant.low),
      'medium' || '보통' || '중간' => ('보통', AppBadgeSmallVariant.medium),
      'high' || '높음' || '많음' || '과다' => ('높음', AppBadgeSmallVariant.high),
      _ => (normalized, AppBadgeSmallVariant.gray),
    };
  }

  static (String label, AppBadgeSmallVariant variant) pollutionRetentionBadge(
    MeasureResultRecord record,
  ) {
    final impact = hairImpactPercent(record);
    if (impact <= 20) {
      return ('낮음', AppBadgeSmallVariant.low);
    }
    if (impact <= 35) {
      return ('보통', AppBadgeSmallVariant.medium);
    }
    return ('높음', AppBadgeSmallVariant.high);
  }

  static (String label, AppBadgeSmallVariant variant) badgeForHairThickness(
    String? raw, {
    String fallbackLabel = '-',
  }) => MetricBadgeMapper.badgeForHairThickness(
    raw,
    fallbackLabel: fallbackLabel,
  );

  static (String label, AppBadgeSmallVariant variant) badgeForHairAttribute(
    String? raw, {
    String fallbackLabel = '-',
  }) {
    return badgeForHairLevel(raw, fallbackLabel: fallbackLabel);
  }

  static (String, AppBadgeSmallVariant) sectionBadge(int score) {
    final level = careLevelFromPollutionScore(score);
    return switch (level) {
      MeasureCareLevel.notRequired ||
      MeasureCareLevel.normal => ('케어 필요 낮음', AppBadgeSmallVariant.low),
      MeasureCareLevel.recommended => ('케어 필요 보통', AppBadgeSmallVariant.medium),
      MeasureCareLevel.intensiveRecommended ||
      MeasureCareLevel.intensiveRequired => (
        '케어 필요 높음',
        AppBadgeSmallVariant.veryHigh,
      ),
    };
  }

  static String odorAnalysis(int score) {
    final level = careLevelFromPollutionScore(score);
    return switch (level) {
      MeasureCareLevel.notRequired ||
      MeasureCareLevel.normal => '외부 냄새 반응이 거의 감지되지 않았어요. 현재 상태를 유지하면 충분해요.',
      MeasureCareLevel.recommended =>
        '가벼운 외부 냄새 반응이 감지됐어요. 필요 시 냄새 케어를 고려해 보세요.',
      _ =>
        '음식 냄새와 땀 냄새 계열의 반응이 함께 나타났어요.\n가까운 거리에서 인지될 가능성이 있어 대면 활동 전\n냄새 케어를 권장해요.',
    };
  }

  static String dustAnalysis(int score) {
    final level = careLevelFromPollutionScore(score);
    return switch (level) {
      MeasureCareLevel.notRequired ||
      MeasureCareLevel.normal => '머리카락 표면의 먼지 반응이 낮아요. 별도 먼지 케어는 필요하지 않아요.',
      MeasureCareLevel.recommended => '소량의 미세 입자가 감지됐어요. 가벼운 먼지 케어를 고려해 보세요.',
      _ => '외부 활동 중 붙은 미세 입자가 일부 감지됐어요.\n모발 표면을 가볍게 정리하는 먼지 케어가 필요해요.',
    };
  }

  static (String, AppBadgeSmallVariant) hairConditionBadge(
    MeasureResultRecord record,
  ) {
    if (record.totalPollutionScore <= recommendedThresholdPercent) {
      return ('컨디션 영향 낮음', AppBadgeSmallVariant.low);
    }
    return ('컨디션 영향 낮음', AppBadgeSmallVariant.low);
  }

  static String hairAnalysis(MeasureResultRecord record) {
    if (record.totalPollutionScore <= recommendedThresholdPercent) {
      return '현재 모발 컨디션이 양호해요. 가벼운 관리로 충분히 상태를 유지할 수 있어요.';
    }
    return '현재 모발 컨디션이 오염을 오래 붙잡는 영향은 낮은 편이에요.\n모발 자체의 잔류 영향은 크지 않지만, 이미 감지된 냄새와 먼지 반응이 있어\n제거 중심 리프레시가 필요해요.';
  }

  static List<String> parseSmellTypes(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const [];
    }

    return raw
        .split(RegExp(r'[,/|]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }

  static MeasureResultDetailMetric smellTypeMetric(MeasureResultRecord record) {
    final types = parseSmellTypes(record.smellType);
    if (types.isEmpty) {
      return const MeasureResultDetailMetric(
        label: '냄새 유형',
        badgeLabel: '-',
        badgeVariant: AppBadgeSmallVariant.gray,
      );
    }

    if (types.length == 1) {
      return MeasureResultDetailMetric(
        label: '냄새 유형',
        badgeLabel: types.first,
        badgeVariant: AppBadgeSmallVariant.gray,
      );
    }

    return MeasureResultDetailMetric(
      label: '냄새 유형',
      tagLabels: types.sublist(0, types.length - 1),
      badgeLabel: types.last,
      badgeVariant: AppBadgeSmallVariant.gray,
    );
  }
}
