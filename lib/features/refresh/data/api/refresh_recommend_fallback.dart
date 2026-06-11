import '../../../home/data/model/environment_snapshot.dart';
import '../model/refresh_mode.dart';

/// Gemini 실패 시 규칙 기반 모드 추천.
class RefreshRecommendFallback {
  const RefreshRecommendFallback._();

  static RefreshMode? pickMode({
    required List<RefreshMode> candidates,
    required EnvironmentSnapshot environment,
  }) {
    if (candidates.isEmpty) {
      return null;
    }

    if (environment.isSnowing || environment.isRaining) {
      final weatherMode = _firstByCategory(candidates, RefreshModeTabs.weather);
      if (weatherMode != null) {
        return weatherMode;
      }
    }

    if (environment.humidityPercent >= 70) {
      final afterOuting = _firstByCategory(
        candidates,
        RefreshModeTabs.afterOuting,
      );
      if (afterOuting != null) {
        return afterOuting;
      }

      final weatherMode = _firstByCategory(candidates, RefreshModeTabs.weather);
      if (weatherMode != null) {
        return weatherMode;
      }
    }

    final beforeOuting = _firstByCategory(
      candidates,
      RefreshModeTabs.beforeOuting,
    );
    return beforeOuting ?? candidates.first;
  }

  static RefreshMode? _firstByCategory(
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
}
