import '../widgets/app_badge.dart';

/// 오염·모발 지표 배지 라벨/variant — measure·refresh 상세 화면 공통.
class MetricBadgeMapper {
  const MetricBadgeMapper._();

  static String pollutionScoreLabel(int score) {
    if (score <= 25) {
      return '매우낮음';
    }
    if (score <= 45) {
      return '낮음';
    }
    if (score <= 65) {
      return '보통';
    }
    if (score <= 85) {
      return '높음';
    }
    return '매우높음';
  }

  static AppBadgeSmallVariant pollutionScoreVariant(int score) {
    if (score <= 25) {
      return AppBadgeSmallVariant.low;
    }
    if (score <= 45) {
      return AppBadgeSmallVariant.low;
    }
    if (score <= 65) {
      return AppBadgeSmallVariant.medium;
    }
    if (score <= 85) {
      return AppBadgeSmallVariant.high;
    }
    return AppBadgeSmallVariant.veryHigh;
  }

  static int pollutionScoreStepUp(int score) {
    return (score + 12).clamp(0, 100);
  }

  /// 오염 잔류 영향·모발 손상도 — 높음 / 보통 / 낮음.
  static (String label, AppBadgeSmallVariant variant) badgeForHairLevel(
    String? raw, {
    String fallbackLabel = '-',
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return (fallbackLabel, AppBadgeSmallVariant.gray);
    }

    final normalized = raw.trim();
    final lower = normalized.toLowerCase();

    return switch (lower) {
      'low' || '낮음' => ('낮음', AppBadgeSmallVariant.low),
      'medium' || '보통' || '중간' => ('보통', AppBadgeSmallVariant.medium),
      'high' || '높음' => ('높음', AppBadgeSmallVariant.high),
      _ => (normalized, AppBadgeSmallVariant.gray),
    };
  }

  /// 모발 굵기 — 굵음 / 보통 / 얇음.
  static (String label, AppBadgeSmallVariant variant) badgeForHairThickness(
    String? raw, {
    String fallbackLabel = '-',
  }) {
    if (raw == null || raw.trim().isEmpty) {
      return (fallbackLabel, AppBadgeSmallVariant.gray);
    }

    final normalized = raw.trim();
    final lower = normalized.toLowerCase();

    return switch (lower) {
      '굵은' || '굵음' || 'thick' => ('굵음', AppBadgeSmallVariant.gray),
      '중간' || '보통' || 'medium' => ('보통', AppBadgeSmallVariant.gray),
      '가는' || '가늬' || '가늠' || 'thin' => ('얇음', AppBadgeSmallVariant.gray),
      _ => (normalized, AppBadgeSmallVariant.gray),
    };
  }
}
