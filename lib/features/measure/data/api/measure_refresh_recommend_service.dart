import '../../../../app/theme/app_colors.dart';
import '../../../refresh/data/api/refresh_api.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../refresh/data/refresh_mode_catalog.dart';
import '../../../../shared/recommendation/refresh_recommend_service.dart';
import 'measure_diagnosis_generator.dart';
import '../model/measure_result.dart';
import '../model/measure_result_headline.dart';
import '../model/measure_result_record.dart';
import 'measure_api.dart';
import 'measure_result_mapper.dart';
import '../model/measure_care_level.dart';

/// 진단 결과와 통합 Gemini 추천을 조합해 [MeasureResult]를 생성합니다.
class MeasureRefreshRecommendService {
  MeasureRefreshRecommendService({
    this.measureApi = const MeasureApi(),
    this.refreshApi = const RefreshApi(),
    RefreshRecommendService? recommendService,
  }) : recommendService = recommendService ?? RefreshRecommendService.instance;

  final MeasureApi measureApi;
  final RefreshApi refreshApi;
  final RefreshRecommendService recommendService;

  /// 진단 분석 단계: 고오염 점수를 생성해 DB에 저장한 뒤 결과를 조합합니다.
  Future<MeasureResult> runDiagnosis({DateTime? now}) async {
    final payload = MeasureDiagnosisGenerator.generateHighPollution();
    final record = await measureApi.insertDiagnosisResult(payload: payload);
    return buildMeasureResult(sourceRecord: record, now: now);
  }

  Future<MeasureResult> buildMeasureResult({
    MeasureResultRecord? sourceRecord,
    MeasureCareLevel? odorLevel,
    MeasureCareLevel? dustLevel,
    DateTime? now,
  }) async {
    final record = sourceRecord ?? await measureApi.fetchLatestResult();
    if (record == null) {
      throw const MeasureApiException('저장된 진단 결과가 없습니다.');
    }

    final resolvedOdor = odorLevel ?? MeasureResultMapper.odorLevel(record);
    final resolvedDust = dustLevel ?? MeasureResultMapper.dustLevel(record);

    final presets = await refreshApi.fetchPresetModes();
    RefreshPresetModeStore.instance.setPresets(presets);

    final recommendation = await recommendService.resolve(
      forceRefresh: sourceRecord != null,
      now: now,
    );

    final recommendedMode = recommendation?.mode ?? _fallbackMode(presets);
    final recommendReason =
        recommendation?.message ??
        '현재 헤어 상태와 환경을 고려해 ${recommendedMode.name}을 추천해요.';
    return MeasureResult(
      odorLevel: resolvedOdor,
      dustLevel: resolvedDust,
      headline: _headlineFor(resolvedOdor, resolvedDust),
      recommendedMode: recommendedMode,
      recommendReason: recommendReason,
      sourceRecord: record,
    );
  }

  static MeasureResultHeadline _headlineFor(
    MeasureCareLevel odorLevel,
    MeasureCareLevel dustLevel,
  ) {
    if (odorLevel.needsAction || dustLevel.needsAction) {
      return MeasureResultHeadline.highlighted(
        before: '외출 후 남은 냄새와 먼지를 정리해 ',
        highlight: '안심할 수 있는 상태',
        after: '를 되찾아보세요.',
        highlightColor: AppColors.orange700,
      );
    }

    return MeasureResultHeadline.plain('현재 헤어 상태는 안정적이에요.\n가벼운 관리만으로 충분해요.');
  }

  static RefreshMode _fallbackMode(List<RefreshMode> presets) {
    if (presets.isEmpty) {
      return RefreshRecommendService.fallbackMode();
    }

    for (final mode in presets) {
      if (mode.category == RefreshModeTabs.afterOuting &&
          mode.odorYn &&
          mode.dustYn) {
        return mode;
      }
    }

    return presets.first;
  }
}
