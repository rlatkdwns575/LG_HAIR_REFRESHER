import '../../../../shared/recommendation/refresh_recommend_category.dart';
import '../../../../shared/recommendation/refresh_recommend_input.dart';
import '../../../../shared/recommendation/refresh_recommend_measure_rules.dart';
import '../../../../shared/recommendation/refresh_recommend_schedule_snapshot.dart';
import '../../../home/data/model/environment_snapshot.dart';
import '../model/refresh_mode.dart';

/// 규칙 기반 모드 추천. 측정이 있으면 점수 우선, 날씨·일정은 카테고리 보조.
class RefreshRecommendFallback {
  const RefreshRecommendFallback._();

  static RefreshMode? pickMode({
    required List<RefreshMode> candidates,
    required RefreshRecommendInput context,
  }) {
    if (context.includesMeasure && context.measure != null) {
      final measure = context.measure!;
      final filtered = RefreshRecommendMeasureRules.filterForMeasure(
        measure,
        candidates,
      );
      final pool = filtered.isNotEmpty ? filtered : candidates;
      final fromMeasure = RefreshRecommendMeasureRules.pickFromMeasure(
        measure,
        pool,
        environment: context.environment,
        schedule: context.schedule,
      );
      if (fromMeasure != null) {
        return fromMeasure;
      }
    }

    return pickModeFromEnvironment(
      candidates: candidates,
      environment: context.environment,
      schedule: context.schedule,
    );
  }

  static RefreshMode? pickModeFromEnvironment({
    required List<RefreshMode> candidates,
    required EnvironmentSnapshot environment,
    RefreshRecommendScheduleSnapshot? schedule,
  }) {
    if (candidates.isEmpty) {
      return null;
    }

    final category = RefreshRecommendCategory.preferred(
      environment: environment,
      schedule: schedule,
    );
    if (category != null) {
      final matched = RefreshRecommendCategory.firstByCategory(
        candidates,
        category,
      );
      if (matched != null) {
        return matched;
      }

      if (category == RefreshModeTabs.weather) {
        final afterOuting = RefreshRecommendCategory.firstByCategory(
          candidates,
          RefreshModeTabs.afterOuting,
        );
        if (afterOuting != null) {
          return afterOuting;
        }
      }
    }

    final beforeOuting = RefreshRecommendCategory.firstByCategory(
      candidates,
      RefreshModeTabs.beforeOuting,
    );
    return beforeOuting ?? candidates.first;
  }
}
