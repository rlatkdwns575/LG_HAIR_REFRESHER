import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_section_title.dart';
import '../../data/model/refresh_history_report.dart';
import 'history_common.dart';

/// Section 3 — 전체 리프레시 기록 인사이트.
class HistoryTotalSection extends StatelessWidget {
  const HistoryTotalSection({required this.summary, super.key});

  final RefreshTotalSummary summary;

  String _formatPercent(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final bestMode = summary.bestImprovementMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppSectionTitle(
          title: '전체 리프레시 기록',
          subtitle: '지금까지의 리프레시 기록을 확인해보세요.',
        ),
        const SizedBox(height: AppSpacing.lg),
        Column(
          children: [
            Text(
              '리프레시가 점점 {이름}님의',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleS.copyWith(color: AppColors.gray800),
            ),
            Text(
              '외출 후 루틴으로 자리 잡고 있어요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleS.copyWith(color: AppColors.gray800),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                labelLines: const ['총 리프레시 횟수'],
                value: '${summary.totalCount}회',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatCard(
                labelLines: const ['리프레시 후 개선도'],
                valueLeading: '평균 ',
                value: _formatPercent(summary.averageImprovementPercent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          insight: summary.preStatePattern,
          titleColor: AppColors.primary500,
          child: _StackedBar(
            bars: summary.preStatePattern.bars,
            barHeight: 14,
            usePrimaryPalette: true,
            highlightPrimaryPercentOnly: true,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          insight: summary.timeUsageInsight,
          titleColor: AppColors.primary500,
          child: _TimeUsageChart(usages: summary.timeUsage),
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          insight: summary.careRatio,
          titleColor: AppColors.primary500,
          child: _GradientStackedBar(bars: summary.careRatio.bars),
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          title: '주요 리프레시 모드',
          titleColor: AppColors.primary500,
          descriptions: [summary.modeUsageDescription],
          child: Column(
            children: [
              for (var i = 0; i < summary.modeUsages.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _ModeUsageRow(
                  usage: summary.modeUsages[i],
                  highlight:
                      bestMode != null &&
                      identical(summary.modeUsages[i], bestMode),
                  improvementLabel:
                      '${_formatPercent(summary.modeUsages[i].improvementPercent)} 개선',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.labelLines,
    required this.value,
    this.valueLeading,
  });

  final List<String> labelLines;
  final String value;
  final String? valueLeading;

  @override
  Widget build(BuildContext context) {
    return HistoryWhiteCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (var i = 0; i < labelLines.length; i++)
            Text(
              labelLines[i],
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 10),
          if (valueLeading == null)
            Text(
              value,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineM.copyWith(color: AppColors.gray900),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  valueLeading!,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.headlineM.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 인사이트 한 블록 — 흰 카드 + 제목·설명·콘텐츠.
class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.child,
    this.insight,
    this.title,
    this.descriptions = const [],
    this.titleColor,
  }) : assert(insight != null || title != null);

  final HistoryInsight? insight;
  final String? title;
  final List<String> descriptions;
  final Color? titleColor;
  final Widget child;

  String get _title => insight?.title ?? title!;
  List<String> get _descriptions => insight?.descriptions ?? descriptions;

  @override
  Widget build(BuildContext context) {
    return HistoryWhiteCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _title,
            style: AppTextStyles.labelM.copyWith(
              color: titleColor ?? AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _descriptions.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i < _descriptions.length - 1 ? 4 : 0,
              ),
              child: Text(
                _descriptions[i],
                style: i == 0
                    ? AppTextStyles.bodyM2.copyWith(color: AppColors.gray900)
                    : AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({
    required this.bars,
    this.barHeight = 8,
    this.usePrimaryPalette = false,
    this.highlightPrimaryPercentOnly = false,
  });

  final List<HistoryBarStat> bars;
  final double barHeight;
  final bool usePrimaryPalette;
  final bool highlightPrimaryPercentOnly;

  Color _barColor(HistoryBarStat bar, int index) {
    if (!usePrimaryPalette) {
      return bar.color;
    }
    return index == 0 ? AppColors.primary500 : AppColors.primary200;
  }

  Color _labelColor(HistoryBarStat bar, int index) {
    if (!usePrimaryPalette) {
      return bar.color;
    }
    return index == 0 ? AppColors.primary500 : AppColors.primary400;
  }

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = bars.fold<double>(0, (sum, bar) => sum + bar.percent);
    final safeTotal = total == 0 ? 1 : total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildBarLabel(bars.first, 0),
            const Spacer(),
            if (bars.length > 1)
              _buildBarLabel(bars.last, bars.length - 1, alignRight: true),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Row(
            children: [
              for (var i = 0; i < bars.length; i++)
                Expanded(
                  flex: ((bars[i].percent / safeTotal) * 1000).round().clamp(
                    1,
                    1000,
                  ),
                  child: Container(
                    height: barHeight,
                    color: _barColor(bars[i], i),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarLabel(
    HistoryBarStat bar,
    int index, {
    bool alignRight = false,
  }) {
    final percentText = _format(bar.percent);
    final labelStyle = AppTextStyles.labelM.copyWith(
      color: AppColors.gray900,
      fontWeight: FontWeight.w600,
    );

    if (usePrimaryPalette && highlightPrimaryPercentOnly) {
      if (index == 0) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${bar.label} ', style: labelStyle),
              TextSpan(
                text: percentText,
                style: labelStyle.copyWith(color: AppColors.primary500),
              ),
            ],
          ),
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
        );
      }
      return Text(
        '${bar.label} $percentText',
        style: labelStyle,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
      );
    }

    return Text(
      '${bar.label} $percentText',
      style: AppTextStyles.labelM.copyWith(color: _labelColor(bar, index)),
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }
}

/// 주요 케어 비중 — 좌측 그라데이션 + 우측 연한 블루.
class _GradientStackedBar extends StatelessWidget {
  const _GradientStackedBar({required this.bars});

  final List<HistoryBarStat> bars;

  static const _barHeight = 14.0;

  @override
  Widget build(BuildContext context) {
    if (bars.length < 2) {
      return _StackedBar(bars: bars, barHeight: _barHeight);
    }

    final primary = bars.first;
    final secondary = bars.last;
    final total = primary.percent + secondary.percent;
    final safeTotal = total == 0 ? 1 : total;
    final primaryFlex = ((primary.percent / safeTotal) * 1000).round().clamp(
      1,
      1000,
    );
    final secondaryFlex = ((secondary.percent / safeTotal) * 1000)
        .round()
        .clamp(1, 1000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _buildCareLabel(primary, highlightPercent: true),
            const Spacer(),
            _buildCareLabel(secondary),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Row(
            children: [
              Expanded(
                flex: primaryFlex,
                child: Container(
                  height: _barHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary500, AppColors.primary400],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: secondaryFlex,
                child: Container(
                  height: _barHeight,
                  color: AppColors.primary200,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareLabel(HistoryBarStat bar, {bool highlightPercent = false}) {
    final percentText = _format(bar.percent);
    final labelStyle = AppTextStyles.labelM.copyWith(
      color: AppColors.gray900,
      fontWeight: FontWeight.w600,
    );

    if (highlightPercent) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${bar.label} ', style: labelStyle),
            TextSpan(
              text: percentText,
              style: labelStyle.copyWith(color: AppColors.primary500),
            ),
          ],
        ),
      );
    }

    return Text(
      '${bar.label} $percentText',
      style: labelStyle,
      textAlign: TextAlign.right,
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }
}

class _TimeUsageChart extends StatelessWidget {
  const _TimeUsageChart({required this.usages});

  final List<TimeRangeUsage> usages;

  static const _chartSize = 120.0;

  static const _hourLabelStyle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.gray500,
    height: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _chartSize,
          height: _chartSize,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(_chartSize, _chartSize),
                painter: _ClockDonutPainter(usages: usages),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Text(
                  '24',
                  textAlign: TextAlign.center,
                  style: _hourLabelStyle,
                ),
              ),
              const Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(child: Text('6', style: _hourLabelStyle)),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Text(
                  '12',
                  textAlign: TextAlign.center,
                  style: _hourLabelStyle,
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(child: Text('18', style: _hourLabelStyle)),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < usages.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _LegendRow(usage: usages[i], highlight: i == 0),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.usage, required this.highlight});

  final TimeRangeUsage usage;
  final bool highlight;

  static const _chipWidth = 48.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _chipWidth,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _CountChip(count: usage.count),
          ),
        ),
        Expanded(
          child: Text(
            usage.label,
            style: AppTextStyles.bodyS.copyWith(
              color: highlight ? AppColors.primary500 : AppColors.gray900,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count회',
        style: AppTextStyles.labelS.copyWith(
          color: AppColors.primary500,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ClockDonutPainter extends CustomPainter {
  _ClockDonutPainter({required this.usages});

  final List<TimeRangeUsage> usages;

  static double _hourToAngle(int hour) =>
      (hour / 24.0) * 2 * math.pi - math.pi / 2;

  static double _hourSpan(int startHour, int endHour) =>
      ((endHour - startHour) / 24.0) * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 11.0;
    const labelInset = 10.0;
    final radius = (size.width / 2) - strokeWidth / 2 - labelInset;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = AppColors.gray100,
    );

    if (usages.isEmpty) {
      return;
    }

    // 작은 구간부터 그려 큰 구간이 위에 보이도록.
    final sorted = List<TimeRangeUsage>.from(usages)
      ..sort(
        (a, b) => (a.endHour - a.startHour).compareTo(b.endHour - b.startHour),
      );

    for (final usage in sorted) {
      final startAngle = _hourToAngle(usage.startHour);
      final sweep = _hourSpan(usage.startHour, usage.endHour);
      if (sweep <= 0) {
        continue;
      }

      canvas.drawArc(
        rect,
        startAngle,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt
          ..strokeWidth = strokeWidth
          ..color = usage.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ClockDonutPainter oldDelegate) =>
      oldDelegate.usages != usages;
}

class _ModeUsageRow extends StatelessWidget {
  const _ModeUsageRow({
    required this.usage,
    required this.highlight,
    required this.improvementLabel,
  });

  final ModeUsage usage;
  final bool highlight;
  final String improvementLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _CountChip(count: usage.count),
          ),
        ),
        Expanded(
          child: Text(
            usage.modeName,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(
              color: highlight ? AppColors.primary500 : AppColors.gray700,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        SizedBox(
          width: 72,
          child: Text(
            improvementLabel,
            textAlign: TextAlign.right,
            style: AppTextStyles.labelM.copyWith(
              color: highlight ? AppColors.primary500 : AppColors.gray500,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
