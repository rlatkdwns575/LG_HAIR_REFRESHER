import '../../features/home/data/model/environment_snapshot.dart';
import '../../features/refresh/data/model/refresh_mode.dart';
import 'refresh_recommend_schedule_snapshot.dart';

/// 날씨·일정으로 외출 전/후/날씨 카테고리를 고릅니다.
class RefreshRecommendCategory {
  const RefreshRecommendCategory._();

  /// 비·눈 → 날씨, 다가올 일정 → 외출 전, 진행/종료 일정 → 외출 후,
  /// 고습 → 외출 후. 해당 신호가 없으면 null.
  static String? preferred({
    EnvironmentSnapshot? environment,
    RefreshRecommendScheduleSnapshot? schedule,
  }) {
    if (environment != null &&
        (environment.isSnowing || environment.isRaining)) {
      return RefreshModeTabs.weather;
    }

    final timing = _scheduleTiming(schedule);
    if (timing == 'before') {
      return RefreshModeTabs.beforeOuting;
    }
    if (timing == 'during' || timing == 'after') {
      return RefreshModeTabs.afterOuting;
    }

    if (environment != null && environment.humidityPercent >= 70) {
      return RefreshModeTabs.afterOuting;
    }

    return null;
  }

  static RefreshMode? firstByCategory(
    List<RefreshMode> candidates,
    String category,
  ) {
    for (final mode in candidates) {
      if (mode.category == category) {
        return mode;
      }
    }
    return null;
  }

  static String? _scheduleTiming(RefreshRecommendScheduleSnapshot? schedule) {
    if (schedule == null || !schedule.hasEventsToday) {
      return null;
    }

    final next = schedule.nextEvent;
    if (next != null && next.timing.isNotEmpty) {
      return next.timing;
    }

    for (final event in schedule.todayEvents) {
      if (event.timing == 'during' || event.timing == 'after') {
        return event.timing;
      }
    }

    if (schedule.todayEvents.isEmpty) {
      return null;
    }
    return schedule.todayEvents.first.timing;
  }
}
