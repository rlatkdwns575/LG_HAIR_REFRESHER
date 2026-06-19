import '../../../../app/theme/app_component_colors.dart';
import 'measure_result_status_item.dart';

/// 항목별 케어 필요도 (냄새/먼지).
///
/// 화면설계서 · Figma `badge_small` (532:18430) 상태별 컬러와 매핑됩니다.
enum MeasureCareLevel {
  notRequired('불필요'),
  normal('보통'),
  recommended('권장'),
  intensiveRecommended('집중 권장'),
  intensiveRequired('집중 필요');

  const MeasureCareLevel(this.label);

  final String label;

  /// 냄새/먼지 중 하나라도 [intensiveRecommended] 이상이면 경고형 결과 화면.
  bool get needsAction =>
      this == MeasureCareLevel.intensiveRecommended ||
      this == MeasureCareLevel.intensiveRequired;

  /// 간편보기 결과 화면 배지 문구 (매우나쁨 · 나쁨 · 약간나쁨 · 보통 · 좋음).
  String get simpleViewBadgeLabel => switch (this) {
    MeasureCareLevel.notRequired => '좋음',
    MeasureCareLevel.normal => '보통',
    MeasureCareLevel.recommended => '약간나쁨',
    MeasureCareLevel.intensiveRecommended => '나쁨',
    MeasureCareLevel.intensiveRequired => '매우나쁨',
  };

  MeasureResultStatusItem toStatusItem(
    String categoryLabel, {
    String? badgeLabel,
  }) {
    final resolvedBadgeLabel = badgeLabel ?? label;
    return switch (this) {
      MeasureCareLevel.notRequired => MeasureResultStatusItem(
        categoryLabel: categoryLabel,
        badgeLabel: resolvedBadgeLabel,
        dotColor: AppComponentColors.badgeSmallLowText,
        badgeBackgroundColor: AppComponentColors.badgeSmallLowBackground,
        badgeTextColor: AppComponentColors.badgeSmallLowText,
      ),
      MeasureCareLevel.normal => MeasureResultStatusItem(
        categoryLabel: categoryLabel,
        badgeLabel: resolvedBadgeLabel,
        dotColor: AppComponentColors.badgeSmallCareNormalText,
        badgeBackgroundColor: AppComponentColors.badgeSmallCareNormalBackground,
        badgeTextColor: AppComponentColors.badgeSmallCareNormalText,
      ),
      MeasureCareLevel.recommended => MeasureResultStatusItem(
        categoryLabel: categoryLabel,
        badgeLabel: resolvedBadgeLabel,
        dotColor: AppComponentColors.badgeSmallMediumFilledBackground,
        badgeBackgroundColor: AppComponentColors.badgeSmallMediumBackground,
        badgeTextColor: AppComponentColors.badgeSmallMediumText,
      ),
      MeasureCareLevel.intensiveRecommended => MeasureResultStatusItem(
        categoryLabel: categoryLabel,
        badgeLabel: resolvedBadgeLabel,
        dotColor: AppComponentColors.badgeSmallHighText,
        badgeBackgroundColor: AppComponentColors.badgeSmallHighBackground,
        badgeTextColor: AppComponentColors.badgeSmallHighText,
      ),
      MeasureCareLevel.intensiveRequired => MeasureResultStatusItem(
        categoryLabel: categoryLabel,
        badgeLabel: resolvedBadgeLabel,
        dotColor: AppComponentColors.badgeSmallVeryHighText,
        badgeBackgroundColor: AppComponentColors.badgeSmallVeryHighBackground,
        badgeTextColor: AppComponentColors.badgeSmallVeryHighText,
      ),
    };
  }
}
