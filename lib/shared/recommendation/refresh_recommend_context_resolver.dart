import 'package:flutter/foundation.dart';

import '../../core/services/local_calendar_service.dart';
import '../../features/home/data/api/weather_api.dart';
import '../../features/home/data/model/environment_snapshot.dart';
import '../../features/measure/data/api/measure_api.dart';
import '../../features/measure/data/model/measure_result_record.dart';
import '../../features/refresh/data/api/refresh_session_api.dart';
import 'refresh_recommend_basis.dart';
import 'refresh_recommend_input.dart';
import 'refresh_recommend_schedule_snapshot.dart';

/// 날씨·측정·일정을 조합해 추천 입력 컨텍스트를 결정합니다.
class RefreshRecommendContextResolver {
  const RefreshRecommendContextResolver({
    this.weatherApi = const WeatherApi(),
    this.measureApi = const MeasureApi(),
    this.refreshSessionApi = const RefreshSessionApi(),
    this.calendarService = const LocalCalendarService(),
    this.measureWindow = const Duration(hours: 2),
  });

  final WeatherApi weatherApi;
  final MeasureApi measureApi;
  final RefreshSessionApi refreshSessionApi;
  final LocalCalendarService calendarService;
  final Duration measureWindow;

  static const EnvironmentSnapshot neutralEnvironment = EnvironmentSnapshot(
    temperatureCelsius: 22,
    humidityPercent: 50,
    isRaining: false,
    isSnowing: false,
  );

  Future<RefreshRecommendInput> resolve({DateTime? now, String? userId}) async {
    final resolvedNow = now ?? DateTime.now();
    final environment = await _loadEnvironment();
    final schedule = RefreshRecommendScheduleSnapshot.fromCalendarStatus(
      await calendarService.fetchStatus(),
    );

    final latestMeasure = await measureApi.fetchLatestResult(userId: userId);
    var refreshedAfter = false;
    if (latestMeasure != null) {
      refreshedAfter = await refreshSessionApi.hasCompletedRefreshSinceMeasure(
        measureCreatedAt: latestMeasure.createdAt,
        userId: userId,
      );
    }

    final basis = resolveBasis(
      latestMeasure: latestMeasure,
      refreshedAfterMeasure: refreshedAfter,
      schedule: schedule,
      now: resolvedNow,
      measureWindow: measureWindow,
    );

    debugPrint('RefreshRecommendContextResolver: basis=${basis.name}');

    return buildInput(
      basis: basis,
      environment: environment,
      latestMeasure: latestMeasure,
      schedule: schedule,
    );
  }

  /// 측정·일정·시간 조건으로 추천 근거를 결정합니다.
  static RefreshRecommendBasis resolveBasis({
    required MeasureResultRecord? latestMeasure,
    required bool refreshedAfterMeasure,
    required RefreshRecommendScheduleSnapshot schedule,
    required DateTime now,
    Duration measureWindow = const Duration(hours: 2),
  }) {
    if (latestMeasure != null && !refreshedAfterMeasure) {
      final age = now.difference(latestMeasure.createdAt.toLocal());
      if (age <= measureWindow) {
        return RefreshRecommendBasis.measure;
      }
    }

    if (schedule.hasEventsToday) {
      return RefreshRecommendBasis.weatherAndSchedule;
    }

    return RefreshRecommendBasis.weatherOnly;
  }

  static RefreshRecommendInput buildInput({
    required RefreshRecommendBasis basis,
    required EnvironmentSnapshot environment,
    required MeasureResultRecord? latestMeasure,
    required RefreshRecommendScheduleSnapshot schedule,
  }) {
    return switch (basis) {
      RefreshRecommendBasis.measure => RefreshRecommendInput(
        basis: basis,
        environment: environment,
        measure: latestMeasure,
        schedule: schedule.hasEventsToday ? schedule : null,
      ),
      RefreshRecommendBasis.weatherAndSchedule => RefreshRecommendInput(
        basis: basis,
        environment: environment,
        schedule: schedule,
      ),
      RefreshRecommendBasis.weatherOnly => RefreshRecommendInput(
        basis: basis,
        environment: environment,
      ),
    };
  }

  Future<EnvironmentSnapshot> _loadEnvironment() async {
    try {
      return await weatherApi.fetchSnapshot();
    } catch (error, stackTrace) {
      debugPrint(
        'RefreshRecommendContextResolver weather failed: $error\n$stackTrace',
      );
      return neutralEnvironment;
    }
  }
}
