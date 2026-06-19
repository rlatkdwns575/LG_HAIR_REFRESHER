import '../../../../shared/widgets/app_badge.dart';

/// 냄새/먼지 케어 상태 단계.
///
/// 배지는 Figma `badge_small` (532:18430) → [AppBadge] 와 매핑됩니다.
enum CareStatus {
  focusedRecommend('집중권장'),
  focusedRequired('집중필요'),
  recommend('권장'),
  good('좋음'),
  normal('보통'),
  notNeeded('불필요');

  const CareStatus(this.label);

  final String label;

  /// Figma badge_small variant (text 스타일).
  AppBadgeSmallVariant get badgeVariant => switch (this) {
    CareStatus.good => AppBadgeSmallVariant.low,
    CareStatus.normal => AppBadgeSmallVariant.careNormal,
    CareStatus.recommend => AppBadgeSmallVariant.medium,
    CareStatus.focusedRecommend => AppBadgeSmallVariant.high,
    CareStatus.focusedRequired => AppBadgeSmallVariant.veryHigh,
    CareStatus.notNeeded => AppBadgeSmallVariant.primaryLight,
  };

  /// API/Supabase 의 문자열 코드 → enum 매핑. 미매칭 시 [normal] 반환.
  static CareStatus fromCode(String? code) {
    return CareStatus.values.firstWhere(
      (status) => status.name == code || status.label == code,
      orElse: () => CareStatus.normal,
    );
  }
}
