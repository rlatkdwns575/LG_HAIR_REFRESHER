import 'package:flutter/material.dart';

import '../../../home/data/api/weather_api.dart';
import '../../../home/data/model/environment_snapshot.dart';
import '../../../refresh/data/api/refresh_api.dart';
import '../../../refresh/data/model/refresh_mode.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../refresh/data/refresh_mode_catalog.dart';
import '../measure_pollution_mapper.dart';
import '../measure_refresh_recommend_engine.dart';
import '../model/measure_care_level.dart';
import '../model/measure_refresh_recommend_input.dart';
import '../model/measure_result.dart';
import '../model/measure_result_headline.dart';
import 'measure_schedule_classifier_api.dart';

/// 진단 결과와 리프레시 모드 추천을 조합해 [MeasureResult]를 생성합니다.
class MeasureRefreshRecommendService {
  const MeasureRefreshRecommendService({
    this.refreshApi = const RefreshApi(),
    this.weatherApi = const WeatherApi(),
    this.scheduleClassifierApi = const MeasureScheduleClassifierApi(),
  });

  final RefreshApi refreshApi;
  final WeatherApi weatherApi;
  final MeasureScheduleClassifierApi scheduleClassifierApi;

  static const _mockOdorLevel = MeasureCareLevel.intensiveRecommended;
  static const _mockDustLevel = MeasureCareLevel.intensiveRequired;

  static const EnvironmentSnapshot _neutralEnvironment = EnvironmentSnapshot(
    temperatureCelsius: 22,
    humidityPercent: 50,
    isRaining: false,
    isSnowing: false,
  );

  Future<MeasureResult> buildMeasureResult({
    MeasureCareLevel? odorLevel,
    MeasureCareLevel? dustLevel,
    DateTime? now,
  }) async {
    final resolvedOdor = odorLevel ?? _mockOdorLevel;
    final resolvedDust = dustLevel ?? _mockDustLevel;
    final resolvedNow = now ?? DateTime.now();

    final presets = await refreshApi.fetchPresetModes();
    RefreshPresetModeStore.instance.setPresets(presets);

    final environment = await _loadEnvironment();
    final scheduleCategory = await scheduleClassifierApi.classify();
    final scheduleTiming = await scheduleClassifierApi.resolveTiming(
      now: resolvedNow,
    );

    final pollution = MeasurePollutionMapper.fromLevels(
      odorLevel: resolvedOdor,
      dustLevel: resolvedDust,
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

    final recommendedMode =
        recommendation?.recommendedMode ?? _fallbackMode(presets);
    final recommendReason =
        recommendation?.reason ??
        '현재 헤어 상태와 환경을 고려해 ${recommendedMode.name}을 추천해요.';

    return MeasureResult(
      odorLevel: resolvedOdor,
      dustLevel: resolvedDust,
      headline: _headlineFor(resolvedOdor, resolvedDust),
      recommendedMode: recommendedMode,
      recommendReason: recommendReason,
    );
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
