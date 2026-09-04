import '../../features/home/data/model/environment_snapshot.dart';
import '../../features/measure/data/api/measure_result_mapper.dart';
import '../../features/measure/data/model/measure_result_record.dart';
import '../../features/refresh/data/model/refresh_mode.dart';
import 'refresh_recommend_candidates.dart';
import 'refresh_recommend_category.dart';
import 'refresh_recommend_schedule_snapshot.dart';

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

  /// 측정 점수로 후보를 좁힌 뒤, 날씨·일정으로 카테고리를 고릅니다.
  static RefreshMode? pickFromMeasure(
    MeasureResultRecord record,
    List<RefreshMode> candidates, {
    EnvironmentSnapshot? environment,
    RefreshRecommendScheduleSnapshot? schedule,
  }) {
    if (candidates.isEmpty) {
      return null;
    }

    final odor = record.hairOdorScore;
    final dust = record.hairDustScore;
    final odorHigh = requiresOdorCare(record);
    final dustHigh = requiresDustCare(record);

    var pool = candidates;
    bool? forOdor;

    if (odor > dust) {
      final focused = _focusedList(candidates: candidates, forOdor: true);
      if (focused.isNotEmpty) {
        pool = focused;
        forOdor = true;
      }
    } else if (dust > odor) {
      final focused = _focusedList(candidates: candidates, forOdor: false);
      if (focused.isNotEmpty) {
        pool = focused;
        forOdor = false;
      }
    } else if (odorHigh && dustHigh) {
      final both = [
        for (final mode in candidates)
          if (mode.odorYn && mode.dustYn) mode,
      ];
      if (both.isNotEmpty) {
        pool = both;
      }
    } else if (odorHigh) {
      final focused = _focusedList(candidates: candidates, forOdor: true);
      if (focused.isNotEmpty) {
        pool = focused;
        forOdor = true;
      }
    } else if (dustHigh) {
      final focused = _focusedList(candidates: candidates, forOdor: false);
      if (focused.isNotEmpty) {
        pool = focused;
        forOdor = false;
      }
    }

    if (pool.isEmpty) {
      return null;
    }

    final category = RefreshRecommendCategory.preferred(
      environment: environment,
      schedule: schedule,
    );
    var narrowed = category == null
        ? pool
        : [
            for (final mode in pool)
              if (mode.category == category) mode,
          ];
    if (narrowed.isEmpty) {
      narrowed = pool;
    }

    if (forOdor != null) {
      return _preferByStrength(narrowed, forOdor: forOdor) ??
          _preferAfterOuting(narrowed);
    }

    return _preferAfterOuting(narrowed) ?? narrowed.first;
  }

  static List<RefreshMode> _focusedList({
    required List<RefreshMode> candidates,
    required bool forOdor,
  }) {
    if (forOdor) {
      final odorOnly = [
        for (final mode in candidates)
          if (mode.odorYn && !mode.dustYn) mode,
      ];
      if (odorOnly.isNotEmpty) {
        return odorOnly;
      }

      return [
        for (final mode in candidates)
          if (mode.odorYn) mode,
      ];
    }

    final dustOnly = [
      for (final mode in candidates)
        if (mode.dustYn && !mode.odorYn) mode,
    ];
    if (dustOnly.isNotEmpty) {
      return dustOnly;
    }

    return [
      for (final mode in candidates)
        if (mode.dustYn) mode,
    ];
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
