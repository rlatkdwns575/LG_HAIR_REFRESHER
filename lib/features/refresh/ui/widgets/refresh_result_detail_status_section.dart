import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../data/model/refresh_result_detail.dart';
import '../../../../shared/widgets/app_metric_help_icon.dart';

/// Figma 1182-20490 — 냄새 / 먼지 / 모발 상태 섹션.
class RefreshResultDetailStatusSection extends StatelessWidget {
  const RefreshResultDetailStatusSection({
    required this.section,
    this.horizontalPadding = 8,
    super.key,
  });

  final RefreshResultStatusSection section;

  /// 섹션 전체 좌우 inset — 제목·카드·지표 row 공통.
  final double horizontalPadding;

  static const _metricRowGap = 12.0;
  static const _metricRowHeight = 24.0;
  static const _cardContentHorizontalPadding = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            section.title,
            style: AppTextStyles.titleM.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          AppText(
            section.description,
            breakLinesBySentence: true,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray500,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _InsightCard(insight: section.insight),
          if (section.changes.isNotEmpty || section.hairMetrics.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _cardContentHorizontalPadding,
              ),
              child: Column(
                children: [
                  if (section.changes.isNotEmpty) ...[
                    for (var i = 0; i < section.changes.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i < section.changes.length - 1
                              ? _metricRowGap
                              : 0,
                        ),
                        child: _StatusChangeRow(change: section.changes[i]),
                      ),
                  ],
                  if (section.hairMetrics.isNotEmpty) ...[
                    for (var i = 0; i < section.hairMetrics.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i < section.hairMetrics.length - 1
                              ? _metricRowGap
                              : 0,
                        ),
                        child: _HairMetricRow(metric: section.hairMetrics[i]),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});

  final RefreshResultStatusInsight insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal:
            RefreshResultDetailStatusSection._cardContentHorizontalPadding,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: insight.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OutlineBadge(
            label: insight.badgeLabel,
            textColor: insight.badgeTextColor,
            borderColor: insight.badgeBorderColor,
            backgroundColor: insight.badgeBackgroundColor,
          ),
          const SizedBox(height: 12),
          AppText(
            insight.description,
            breakLinesBySentence: true,
            textAlign: TextAlign.start,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.gray900,
              fontWeight: FontWeight.w600,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineBadge extends StatelessWidget {
  const _OutlineBadge({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  bool get _showBorder => backgroundColor == AppColors.gray0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: _showBorder ? Border.all(color: borderColor, width: 1) : null,
      ),
      child: AppText(
        label,
        style: AppTextStyles.labelS.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          height: 1.2,
        ),
      ),
    );
  }
}

class _StatusChangeRow extends StatelessWidget {
  const _StatusChangeRow({required this.change});

  final RefreshResultStatusChange change;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RefreshResultDetailStatusSection._metricRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MetricLabel(
                label: change.label,
                showHelpIcon: change.showHelpIcon,
                helpTooltipMessage: change.helpTooltipMessage,
                bold: true,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CompactBadge(
                label: change.beforeLabel,
                variant: change.beforeVariant,
                style: change.beforeStyle,
              ),
              const _FilledTriangleArrow(),
              _CompactBadge(
                label: change.afterLabel,
                variant: change.afterVariant,
                style: change.afterStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HairMetricRow extends StatelessWidget {
  const _HairMetricRow({required this.metric});

  final RefreshResultHairMetric metric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RefreshResultDetailStatusSection._metricRowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _MetricLabel(
                label: metric.label,
                showHelpIcon: metric.showHelpIcon,
                helpTooltipMessage: metric.helpTooltipMessage,
              ),
            ),
          ),
          _CompactBadge(
            label: metric.valueLabel,
            variant: metric.variant,
            style: metric.style,
          ),
        ],
      ),
    );
  }
}

class _MetricLabel extends StatelessWidget {
  const _MetricLabel({
    required this.label,
    this.showHelpIcon = false,
    this.helpTooltipMessage,
    this.bold = false,
  });

  final String label;
  final bool showHelpIcon;
  final String? helpTooltipMessage;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.bodyS.copyWith(
      color: AppColors.gray900,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
    );

    if (showHelpIcon &&
        helpTooltipMessage != null &&
        helpTooltipMessage!.isNotEmpty) {
      return AppMetricHelpIcon(
        label: label,
        labelStyle: labelStyle,
        tooltipMessage: helpTooltipMessage!,
        placement: AppMetricHelpTooltipPlacement.belowStart,
      );
    }

    return AppText(label, style: labelStyle);
  }
}

class _FilledTriangleArrow extends StatelessWidget {
  const _FilledTriangleArrow();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: CustomPaint(
        size: Size(5, 7),
        painter: _FilledTriangleArrowPainter(color: AppColors.gray300),
      ),
    );
  }
}

class _FilledTriangleArrowPainter extends CustomPainter {
  const _FilledTriangleArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _FilledTriangleArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CompactBadge extends StatelessWidget {
  const _CompactBadge({
    required this.label,
    required this.variant,
    required this.style,
  });

  final String label;
  final AppBadgeSmallVariant variant;
  final AppBadgeStyle style;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      smallVariant: variant,
      style: style,
      compact: true,
    );
  }
}
