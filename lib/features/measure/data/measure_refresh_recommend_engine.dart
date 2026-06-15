import '../../refresh/data/model/refresh_mode.dart';
import 'model/measure_refresh_recommend_input.dart';
import 'model/measure_refresh_recommend_result.dart';
import 'model/schedule_category.dart';

/// 진단·날씨·일정 기반 규칙 추천 엔진.
class MeasureRefreshRecommendEngine {
  const MeasureRefreshRecommendEngine._();

  static MeasureRefreshRecommendResult? recommend(
    MeasureRefreshRecommendInput input,
  ) {
    if (input.candidates.isEmpty) {
      return null;
    }

    final context = _RecommendContext.fromInput(input);
    final scores = <String, double>{};

    for (final mode in input.candidates) {
      scores[mode.id] = _scoreMode(mode: mode, context: context);
    }

    final sorted = input.candidates.toList()
      ..sort((a, b) {
        final scoreDiff = scores[b.id]!.compareTo(scores[a.id]!);
        if (scoreDiff != 0) {
          return scoreDiff;
        }
        return _tieBreak(a, b, context).compareTo(0);
      });

    final best = sorted.first;
    return MeasureRefreshRecommendResult(
      recommendedMode: best,
      reason: _buildReason(mode: best, context: context),
      scores: scores,
    );
  }

  static int _tieBreak(
    RefreshMode a,
    RefreshMode b,
    _RecommendContext context,
  ) {
    if (context.odorNeed >= context.dustNeed) {
      final aMatch = a.odorYn ? 1 : 0;
      final bMatch = b.odorYn ? 1 : 0;
      return bMatch.compareTo(aMatch);
    }

    final aMatch = a.dustYn ? 1 : 0;
    final bMatch = b.dustYn ? 1 : 0;
    return bMatch.compareTo(aMatch);
  }

  static double _scoreMode({
    required RefreshMode mode,
    required _RecommendContext context,
  }) {
    var score = 0.0;

    if (mode.odorYn) {
      score += context.odorNeed * _strengthMultiplier(mode.odorStrength);
    }
    if (mode.dustYn) {
      score += context.dustNeed * _strengthMultiplier(mode.dustStrength);
    }

    switch (mode.category) {
      case RefreshModeTabs.beforeOuting:
        score += context.beforeOutingBonus + context.socialNeed;
      case RefreshModeTabs.afterOuting:
        score +=
            context.afterOutingBonus +
            context.odorNeed * 0.3 +
            context.dustNeed * 0.4;
      case RefreshModeTabs.weather:
        score += context.weatherCategoryBonus + context.dustNeed * 0.2;
      case RefreshModeTabs.etc:
        score += context.totalPollution * 0.1;
      default:
        break;
    }

    if (mode.isScentOnlyCare) {
      score += context.socialNeed * 0.4;
      if (context.totalPollution >= 50) {
        score -= 20;
      }
    }

    if (context.sleepBonus > 0) {
      final shortness = (900 - mode.durationSeconds).clamp(0, 900) / 900;
      score += context.sleepBonus * shortness;
    }

    if (context.totalPollution < 30) {
      if (mode.category == RefreshModeTabs.beforeOuting) {
        score += 25;
      }
      if (mode.odorYn && mode.dustYn) {
        score -= 15;
      }
    }

    if (context.scheduleCategory == ScheduleCategory.meal && mode.odorYn) {
      score += 12;
    }
    if (context.scheduleCategory == ScheduleCategory.bbqOrSmokyPlace &&
        mode.odorYn) {
      score += 20;
    }
    if ((context.scheduleCategory == ScheduleCategory.importantMeeting ||
            context.scheduleCategory == ScheduleCategory.dateOrSocial) &&
        mode.category == RefreshModeTabs.beforeOuting) {
      score += 15;
    }

    return score;
  }

  static double _strengthMultiplier(int? strength) {
    return switch (strength) {
      1 => 0.85,
      2 => 1.0,
      3 => 1.15,
      _ => 1.0,
    };
  }

  static String _buildReason({
    required RefreshMode mode,
    required _RecommendContext context,
  }) {
    final factors = <_ReasonFactor>[
      if (context.odorNeed >= 50 || context.dustNeed >= 50)
        _ReasonFactor(
          weight: context.totalPollution,
          text: '냄새·먼지 상태가 집중 관리가 필요하고',
        ),
      if (context.isPrecipitating) _ReasonFactor(weight: 80, text: '비가 예보되어'),
      if (context.humidityPercent >= 70)
        _ReasonFactor(weight: 60, text: '습도가 높아'),
      if (context.humidityPercent <= 30)
        _ReasonFactor(weight: 40, text: '공기가 건조해'),
      if (context.temperatureCelsius <= 5 || context.temperatureCelsius >= 30)
        _ReasonFactor(weight: 35, text: '기온 변화가 커서'),
      if (context.socialNeed >= 20)
        _ReasonFactor(
          weight: context.socialNeed.toDouble(),
          text: '${context.scheduleCategory.careHint} 일정에 맞춰',
        ),
      if (context.beforeOutingBonus >= 8 &&
          context.hour >= 6 &&
          context.hour < 12)
        _ReasonFactor(weight: 25, text: '오전 일정에 맞춰'),
      if (context.afterOutingBonus >= 8 &&
          context.hour >= 12 &&
          context.hour < 19)
        _ReasonFactor(weight: 25, text: '오후 활동 후'),
      if (context.sleepBonus > 0)
        _ReasonFactor(weight: 20, text: '취침 전 가벼운 관리를 위해'),
    ];

    factors.sort((a, b) => b.weight.compareTo(a.weight));

    final lead = factors.isEmpty
        ? '현재 헤어 상태와 환경을 고려해'
        : factors.take(2).map((factor) => factor.text).join(' ');
    return '$lead ${mode.name}을 추천해요.';
  }
}

class _RecommendContext {
  _RecommendContext({
    required this.odorNeed,
    required this.dustNeed,
    required this.socialNeed,
    required this.totalPollution,
    required this.beforeOutingBonus,
    required this.afterOutingBonus,
    required this.weatherCategoryBonus,
    required this.sleepBonus,
    required this.isPrecipitating,
    required this.humidityPercent,
    required this.temperatureCelsius,
    required this.scheduleCategory,
    required this.hour,
  });

  final double odorNeed;
  final double dustNeed;
  final double socialNeed;
  final double totalPollution;
  final double beforeOutingBonus;
  final double afterOutingBonus;
  final double weatherCategoryBonus;
  final double sleepBonus;
  final bool isPrecipitating;
  final int humidityPercent;
  final double temperatureCelsius;
  final ScheduleCategory scheduleCategory;
  final int hour;

  factory _RecommendContext.fromInput(MeasureRefreshRecommendInput input) {
    final category = input.scheduleCategory;
    var odorNeed = input.odorPollution + category.odorImpact;
    var dustNeed = input.dustPollution + category.dustImpact;
    final socialNeed = category.socialImportance.toDouble();
    var beforeOutingBonus = 0.0;
    var afterOutingBonus = 0.0;
    var weatherCategoryBonus = 0.0;
    var sleepBonus = 0.0;

    if (input.isPrecipitating) {
      dustNeed += 15;
      weatherCategoryBonus += 25;
    }
    if (input.humidityPercent >= 70) {
      odorNeed += 10;
      afterOutingBonus += 15;
    }
    if (input.humidityPercent <= 30) {
      beforeOutingBonus += 10;
    }
    if (input.temperatureCelsius <= 5 || input.temperatureCelsius >= 30) {
      weatherCategoryBonus += 10;
    }

    final hour = input.now.hour;
    if (hour >= 6 && hour < 12) {
      beforeOutingBonus += 8;
    } else if (hour >= 12 && hour < 19) {
      afterOutingBonus += 8;
    } else if (hour >= 21 || hour < 6) {
      sleepBonus += 10;
    }

    if (category == ScheduleCategory.importantMeeting ||
        category == ScheduleCategory.dateOrSocial) {
      beforeOutingBonus += 12;
    }
    if (category == ScheduleCategory.commute ||
        category == ScheduleCategory.outdoorActivity ||
        category == ScheduleCategory.exercise) {
      afterOutingBonus += 10;
    }
    if (category == ScheduleCategory.sleepRest) {
      sleepBonus += 12;
    }

    return _RecommendContext(
      odorNeed: odorNeed,
      dustNeed: dustNeed,
      socialNeed: socialNeed,
      totalPollution: input.totalPollution,
      beforeOutingBonus: beforeOutingBonus,
      afterOutingBonus: afterOutingBonus,
      weatherCategoryBonus: weatherCategoryBonus,
      sleepBonus: sleepBonus,
      isPrecipitating: input.isPrecipitating,
      humidityPercent: input.humidityPercent,
      temperatureCelsius: input.temperatureCelsius,
      scheduleCategory: category,
      hour: hour,
    );
  }
}

class _ReasonFactor {
  const _ReasonFactor({required this.weight, required this.text});

  final double weight;
  final String text;
}
