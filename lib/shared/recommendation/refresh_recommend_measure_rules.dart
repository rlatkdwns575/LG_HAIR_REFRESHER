import '../../features/measure/data/api/measure_result_mapper.dart';
import '../../features/measure/data/model/measure_result_record.dart';
import '../../features/refresh/data/model/refresh_mode.dart';
import 'refresh_recommend_candidates.dart';

/// 측정 점수 기반 모드 필터·규칙 추천.
class RefreshRecommendMeasureRules {
  const RefreshRecommendMeasureRules._();

  /// 케어 권장 구간(60% 이상)이면 해당 축 케어가 켜진 모드만 허용합니다.
  static bool requiresOdorCare(MeasureResultRecord record) {
    return record.hairOdorScore >=
        MeasureResultMapper.recommendedThresholdPercent;
  }

  static bool requiresDustCare(MeasureResultRecord record) {
    return record.hairDustScore >=
        MeasureResultMapper.recommendedThresholdPercent;
  }

  /// 측정 점수에 맞는 후보만 남깁니다 (`scent_yn=false` 전제).
  static List<RefreshMode> filterForMeasure(
    MeasureResultRecord record,
    List<RefreshMode> candidates,
  ) {
    var list = RefreshRecommendCandidates.withoutScent(candidates);
    list = [
      for (final mode in list)
        if (!mode.isScentOnlyCare) mode,
    ];

    final odorHigh = requiresOdorCare(record);
    final dustHigh = requiresDustCare(record);
    final odor = record.hairOdorScore;
    final dust = record.hairDustScore;

    if (odorHigh && dustHigh) {
      if (odor > dust) {
        list = [
          for (final mode in list)
            if (mode.odorYn) mode,
        ];
      } else if (dust > odor) {
        list = [
          for (final mode in list)
            if (mode.dustYn) mode,
        ];
      } else {
        list = [
          for (final mode in list)
            if (mode.odorYn && mode.dustYn) mode,
        ];
      }
    } else if (odorHigh) {
      list = [
        for (final mode in list)
          if (mode.odorYn) mode,
      ];
    } else if (dustHigh) {
      list = [
        for (final mode in list)
          if (mode.dustYn) mode,
      ];
    }

    return list;
  }

  /// Gemini 없이 측정 점수·우선순위로 모드를 고릅니다.
  static RefreshMode? pickFromMeasure(
    MeasureResultRecord record,
    List<RefreshMode> candidates,
  ) {
    if (candidates.isEmpty) {
      return null;
    }

    final odor = record.hairOdorScore;
    final dust = record.hairDustScore;
    final odorHigh = requiresOdorCare(record);
    final dustHigh = requiresDustCare(record);

    if (odor > dust) {
      final picked = _pickFocused(candidates: candidates, forOdor: true);
      if (picked != null) {
        return picked;
      }
    }

    if (dust > odor) {
      final picked = _pickFocused(candidates: candidates, forOdor: false);
      if (picked != null) {
        return picked;
      }
    }

    if (odorHigh && dustHigh) {
      final both = candidates.where((mode) => mode.odorYn && mode.dustYn);
      final picked = _preferAfterOuting(both);
      if (picked != null) {
        return picked;
      }
    }

    if (odorHigh) {
      return _pickFocused(candidates: candidates, forOdor: true);
    }
    if (dustHigh) {
      return _pickFocused(candidates: candidates, forOdor: false);
    }

    return _preferAfterOuting(candidates) ?? candidates.first;
  }

  /// Gemini 결과가 측정 규칙과 맞는지 검증하고, 아니면 규칙으로 대체합니다.
  static RefreshMode? ensureValid(
    RefreshMode? picked,
    MeasureResultRecord record,
    List<RefreshMode> presets,
  ) {
    final allowed = filterForMeasure(record, presets);
    final pool = allowed.isNotEmpty
        ? allowed
        : RefreshRecommendCandidates.withoutScent(presets);
    final rulePick = pickFromMeasure(record, pool);

    if (picked != null && pool.any((mode) => mode.id == picked.id)) {
      if (_matchesScoreFocus(picked, record, pool)) {
        return picked;
      }
      return rulePick;
    }

    return rulePick;
  }

  static bool _matchesScoreFocus(
    RefreshMode mode,
    MeasureResultRecord record,
    List<RefreshMode> pool,
  ) {
    final odor = record.hairOdorScore;
    final dust = record.hairDustScore;

    if (odor > dust) {
      final odorOnly = pool.where(
        (candidate) => candidate.odorYn && !candidate.dustYn,
      );
      if (odorOnly.isNotEmpty) {
        return mode.odorYn && !mode.dustYn;
      }
      final best = _pickFocused(candidates: pool, forOdor: true);
      return best?.id == mode.id;
    }

    if (dust > odor) {
      final dustOnly = pool.where(
        (candidate) => candidate.dustYn && !candidate.odorYn,
      );
      if (dustOnly.isNotEmpty) {
        return mode.dustYn && !mode.odorYn;
      }
      final best = _pickFocused(candidates: pool, forOdor: false);
      return best?.id == mode.id;
    }

    return true;
  }

  static RefreshMode? _pickFocused({
    required List<RefreshMode> candidates,
    required bool forOdor,
  }) {
    if (candidates.isEmpty) {
      return null;
    }

    if (forOdor) {
      final odorOnly = [
        for (final mode in candidates)
          if (mode.odorYn && !mode.dustYn) mode,
      ];
      if (odorOnly.isNotEmpty) {
        return _preferAfterOuting(odorOnly);
      }

      final odorModes = [
        for (final mode in candidates)
          if (mode.odorYn) mode,
      ];
      return _preferByStrength(odorModes, forOdor: true) ??
          _preferAfterOuting(odorModes);
    }

    final dustOnly = [
      for (final mode in candidates)
        if (mode.dustYn && !mode.odorYn) mode,
    ];
    if (dustOnly.isNotEmpty) {
      return _preferAfterOuting(dustOnly);
    }

    final dustModes = [
      for (final mode in candidates)
        if (mode.dustYn) mode,
    ];
    return _preferByStrength(dustModes, forOdor: false) ??
        _preferAfterOuting(dustModes);
  }

  static RefreshMode? _preferByStrength(
    List<RefreshMode> modes, {
    required bool forOdor,
  }) {
    if (modes.isEmpty) {
      return null;
    }

    RefreshMode? best;
    var bestScore = -1;
    for (final mode in modes) {
      final score = forOdor
          ? (mode.odorStrength ?? (mode.odorYn ? 2 : 0))
          : (mode.dustStrength ?? (mode.dustYn ? 2 : 0));
      if (score > bestScore) {
        bestScore = score;
        best = mode;
      }
    }

    return best;
  }

  static RefreshMode? _preferAfterOuting(Iterable<RefreshMode> modes) {
    final list = modes.toList();
    if (list.isEmpty) {
      return null;
    }

    for (final mode in list) {
      if (mode.category == RefreshModeTabs.afterOuting) {
        return mode;
      }
    }

    for (final mode in list) {
      if (mode.category == RefreshModeTabs.beforeOuting) {
        return mode;
      }
    }

    return list.first;
  }
}
