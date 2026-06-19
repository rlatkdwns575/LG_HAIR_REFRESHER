import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

export '../../../../core/utils/korean_date_time_format.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_section_divider.dart';

/// Figma 리프레시 기록 리포트 — 공통 텍스트 스타일 (40000026:25686).
abstract final class HistoryTextStyles {
  static final pageTitle = AppTextStyles.titleL.copyWith(
    color: AppColors.gray900,
  );

  static final pageAsOf = AppTextStyles.bodyS.copyWith(
    color: AppColors.gray500,
  );

  /// Title_XS — 카드 제목.
  static final cardTitle = AppTextStyles.titleXs.copyWith(
    color: AppColors.gray900,
  );

  /// Label_M gray700 — 보조 라벨·설명.
  static final labelSecondary = AppTextStyles.labelM.copyWith(
    color: AppColors.gray700,
  );

  /// Label_M gray900 — 본문·값.
  static final labelPrimary = AppTextStyles.labelM.copyWith(
    color: AppColors.gray900,
  );

  /// Label_S primary700 — 증감 수치.
  static final delta = AppTextStyles.labelS.copyWith(
    color: AppColors.primary700,
  );

  static final kvLabel = labelSecondary;
  static final kvValue = labelPrimary;

  static final percentValue = AppTextStyles.labelL.copyWith(
    color: AppColors.gray900,
  );

  static const percentUnit = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColors.gray900,
  );

  static const percentDelta = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1,
    color: AppColors.primary700,
  );

  static final insightTitle = AppTextStyles.labelM.copyWith(
    color: AppColors.primary500,
  );

  static final insightBody = labelPrimary;

  static final insightCaption = AppTextStyles.labelM.copyWith(
    color: AppColors.gray600,
  );

  static final statLabel = AppTextStyles.labelM.copyWith(
    color: AppColors.gray900,
    fontWeight: FontWeight.w700,
  );

  static final statValue = AppTextStyles.titleXs.copyWith(
    color: AppColors.gray900,
    fontWeight: FontWeight.w700,
  );

  static final recordMode = labelPrimary;

  static final recordTime = AppTextStyles.labelM.copyWith(
    color: AppColors.gray500,
  );

  static final detailLink = AppTextStyles.labelM.copyWith(
    color: AppColors.gray500,
  );

  static final barLabel = AppTextStyles.labelM.copyWith(
    color: AppColors.gray900,
    fontWeight: FontWeight.w600,
  );

  static final legendLabel = AppTextStyles.labelM.copyWith(
    color: AppColors.gray900,
  );

  static final legendLabelHighlight = AppTextStyles.labelM.copyWith(
    color: AppColors.primary500,
    fontWeight: FontWeight.w600,
  );

  static final modeUsageName = AppTextStyles.labelM.copyWith(
    color: AppColors.gray700,
  );

  static final modeUsageNameHighlight = AppTextStyles.labelM.copyWith(
    color: AppColors.primary500,
    fontWeight: FontWeight.w700,
  );

  static final modeUsageImprovement = AppTextStyles.labelM.copyWith(
    color: AppColors.gray500,
  );

  static final modeUsageImprovementHighlight = AppTextStyles.labelM.copyWith(
    color: AppColors.primary500,
    fontWeight: FontWeight.w700,
  );
}

/// Figma — ↑ 아이콘 + 증감 텍스트.
class HistoryDeltaText extends StatelessWidget {
  const HistoryDeltaText({required this.delta, this.iconSize = 16, super.key});

  final String delta;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.arrow_upward, size: iconSize, color: AppColors.primary700),
        AppText(delta, style: HistoryTextStyles.delta),
      ],
    );
  }
}

/// Figma — `67` + `%` + ↑`4%`.
class HistoryPercentWithDelta extends StatelessWidget {
  const HistoryPercentWithDelta({
    required this.percentText,
    required this.deltaText,
    super.key,
  });

  final String percentText;
  final String deltaText;

  @override
  Widget build(BuildContext context) {
    final number = percentText.endsWith('%')
        ? percentText.substring(0, percentText.length - 1)
        : percentText;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(number, style: HistoryTextStyles.percentValue),
            Text('%', style: HistoryTextStyles.percentUnit),
          ],
        ),
        const SizedBox(width: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Icon(
                Icons.arrow_upward,
                size: 12,
                color: AppColors.primary700,
              ),
            ),
            Text(deltaText, style: HistoryTextStyles.percentDelta),
          ],
        ),
      ],
    );
  }
}

/// `yyyy년 M월 d일 기준` 형식.
String formatKoreanAsOf(DateTime date) {
  return '${date.year}년 ${date.month}월 ${date.day}일 기준';
}

/// 섹션 사이를 구분하는 두꺼운 회색 구분선.
class HistorySectionDivider extends StatelessWidget {
  const HistorySectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSectionDivider();
  }
}

/// 흰색 라운드 카드 (옅은 테두리).
class HistoryWhiteCard extends StatelessWidget {
  const HistoryWhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.gray0,
    this.borderColor = AppColors.gray100,
    this.borderRadius = 16,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: child,
    );
  }
}

/// `라벨 ... 값` 한 줄 (Figma Label_M 좌·우 정렬).
class HistoryKeyValueRow extends StatelessWidget {
  const HistoryKeyValueRow({
    required this.label,
    required this.value,
    this.trailingDelta,
    this.isPercentValue = false,
    super.key,
  });

  final String label;
  final String value;
  final String? trailingDelta;
  final bool isPercentValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(child: AppText(label, style: HistoryTextStyles.kvLabel)),
        if (trailingDelta != null && isPercentValue)
          HistoryPercentWithDelta(percentText: value, deltaText: trailingDelta!)
        else if (trailingDelta != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(value, style: HistoryTextStyles.kvValue),
              const SizedBox(width: 2),
              HistoryDeltaText(delta: trailingDelta!, iconSize: 12),
            ],
          )
        else
          AppText(value, style: HistoryTextStyles.kvValue),
      ],
    );
  }
}

/// 하루 기록 목록 — 접힘 시 최대 표시 개수.
const historyMaxVisibleDayRecords = 3;

/// 하루 기록 접기/펼치기 토글.
class HistoryRecordsExpandToggle extends StatelessWidget {
  const HistoryRecordsExpandToggle({
    required this.expanded,
    required this.onTap,
    super.key,
  });

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 28,
        child: Center(
          child: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            size: 22,
            color: AppColors.gray400,
          ),
        ),
      ),
    );
  }
}

/// 리포트 카드 우측 상세보기 링크.
class HistoryDetailLink extends StatelessWidget {
  const HistoryDetailLink({required this.label, this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(label, style: HistoryTextStyles.detailLink),
          const Icon(Icons.chevron_right, size: 14, color: AppColors.gray400),
        ],
      ),
    );
  }
}
