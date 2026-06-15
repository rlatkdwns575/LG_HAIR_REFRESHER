import 'package:flutter/material.dart';

import '../../../home/data/api/weather_api.dart';
import '../../../home/data/model/environment_snapshot.dart';
import '../../../refresh/data/api/refresh_api.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../refresh/data/refresh_mode_catalog.dart';
import '../measure_refresh_recommend_engine.dart';
import '../model/measure_care_level.dart';
import '../model/measure_pollution_snapshot.dart';
import '../model/measure_refresh_recommend_input.dart';
import '../model/measure_result.dart';
import '../model/measure_result_headline.dart';
import '../model/measure_result_record.dart';
import 'measure_api.dart';
import 'measure_diagnosis_generator.dart';
import 'measure_result_mapper.dart';
import 'measure_schedule_classifier_api.dart';

/// 진단 결과와 리프레시 모드 추천을 조합해 [MeasureResult]를 생성합니다.
class MeasureRefreshRecommendService {
  const MeasureRefreshRecommendService({
    this.measureApi = const MeasureApi(),
    this.refreshApi = const RefreshApi(),
    this.weatherApi = const WeatherApi(),
    this.scheduleClassifierApi = const MeasureScheduleClassifierApi(),
  });

  final MeasureApi measureApi;
  final RefreshApi refreshApi;
  final WeatherApi weatherApi;
  final MeasureScheduleClassifierApi scheduleClassifierApi;

  static const EnvironmentSnapshot _neutralEnvironment = EnvironmentSnapshot(
    temperatureCelsius: 22,
    humidityPercent: 50,
    isRaining: false,
    isSnowing: false,
  );

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
    final resolvedNow = now ?? DateTime.now();

    final presets = await refreshApi.fetchPresetModes();
    RefreshPresetModeStore.instance.setPresets(presets);

    final environment = await _loadEnvironment();
    final scheduleCategory = await scheduleClassifierApi.classify();
    final scheduleTiming = await scheduleClassifierApi.resolveTiming(
      now: resolvedNow,
    );

    final pollution = MeasurePollutionSnapshot(
      odor: record.hairOdorScore.toDouble(),
      dust: record.hairDustScore.toDouble(),
      total: record.totalPollutionScore.toDouble(),
    );

    final recommendation = MeasureRefreshRecommendEngine.recommend(
      MeasureRefreshRecommendInput(
        odorPollution: pollution.odor,
        dustPollution: pollution.dust,
        totalPollution: pollution.total,
        temperatureCelsius: environment.temperatureCelsius,
        humidityPercent: environment.humidityPercent,
        isPrecipitating: environment.isRaining || environment.isSnowing,
        scheduleCategory: scheduleCategory,
        scheduleTiming: scheduleTiming,
        now: resolvedNow,
        candidates: presets,
      ),
    );

    final recommendedMode = await _resolveRecommendedMode(
      recommendationMode: recommendation?.recommendedMode,
      presets: presets,
    );

    debugPrint(
      'MeasureRefreshRecommendService: using MEASURE_RESULTS '
      '${record.measureId} (odor=${record.hairOdorScore}, '
      'dust=${record.hairDustScore}, total=${record.totalPollutionScore}).',
    );

    return MeasureResult(
      odorLevel: resolvedOdor,
      dustLevel: resolvedDust,
      headline: _headlineFor(resolvedOdor, resolvedDust),
      recommendedMode: recommendedMode,
      recommendReason:
          recommendation?.reason ??
          '현재 헤어 상태와 환경을 고려해 ${recommendedMode.name}을 추천해요.',
      sourceRecord: record,
    );
  }

  Future<RefreshMode> _resolveRecommendedMode({
    required RefreshMode? recommendationMode,
    required List<RefreshMode> presets,
  }) async {
    if (recommendationMode != null) {
      return recommendationMode;
    }

    return _fallbackMode(presets);
  }

  Future<EnvironmentSnapshot> _loadEnvironment() async {
    try {
      return await weatherApi.fetchSnapshot();
    } catch (error, stackTrace) {
      debugPrint(
        'MeasureRefreshRecommendService weather failed: $error\n$stackTrace',
      );
      return _neutralEnvironment;
    }
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
      return const RefreshMode(
        id: 'fallback-refresh',
        name: '리프레시',
        description: '모드를 불러오지 못했습니다.',
        category: RefreshModeTabs.afterOuting,
        durationSeconds: 300,
        icon: Icons.bolt_outlined,
        odorYn: true,
        dustYn: true,
      );
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
