import 'package:flutter/material.dart';

import '../../features/refresh/data/model/refresh_mode.dart';

/// Gemini·규칙 기반 추천에 사용할 후보 모드 필터.
class RefreshRecommendCandidates {
  const RefreshRecommendCandidates._();

  /// 향기 케어(`scent_yn`)가 꺼진 프리셋만 추천 후보로 사용합니다.
  static List<RefreshMode> withoutScent(List<RefreshMode> candidates) {
    return [
      for (final mode in candidates)
        if (!mode.scentYn) mode,
    ];
  }

  /// `scent_yn=false` 후보 중 기본 추천 모드를 고릅니다.
  static RefreshMode? pickDefault(List<RefreshMode> presets) {
    final candidates = withoutScent(presets);
    if (candidates.isEmpty) {
      return null;
    }

    for (final mode in candidates) {
      if (mode.category == RefreshModeTabs.afterOuting &&
          mode.odorYn &&
          mode.dustYn) {
        return mode;
      }
    }

    for (final mode in candidates) {
      if (mode.category == RefreshModeTabs.beforeOuting) {
        return mode;
      }
    }

    return candidates.first;
  }

  /// 프리셋이 없을 때만 쓰는 최소 fallback (`scent_yn=false`).
  static RefreshMode fallbackWhenEmpty() {
    return const RefreshMode(
      id: 'fallback-refresh',
      name: '리프레시',
      description: '모드를 불러오지 못했습니다.',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 300,
      icon: Icons.bolt_outlined,
      odorYn: true,
      dustYn: true,
      scentYn: false,
    );
  }

  static RefreshMode resolveDefault(List<RefreshMode> presets) {
    return pickDefault(presets) ?? fallbackWhenEmpty();
  }
}
