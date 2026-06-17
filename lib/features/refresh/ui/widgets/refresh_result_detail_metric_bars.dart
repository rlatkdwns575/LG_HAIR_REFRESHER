import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_result_detail.dart';

/// Figma 1170-16711 — 요약 Before/After % 세로 막대 3쌍.
class RefreshResultDetailMetricBars extends StatelessWidget {
  const RefreshResultDetailMetricBars({required this.metrics, super.key});

  final List<RefreshResultMetricPair> metrics;

  static const _barMaxHeight = 128.0;
  static const _barWidth = 22.0;
  static const _pairGap = 7.0;
  static const _percentAreaHeight = 28.0;
  static const _guideLinePercent = 66.0;
  static const _labelAreaHeight = 36.0;
  static const _groupGap = 18.0;

  @override
  Widget build(BuildContext context) {
    final guideLineTop =
        _percentAreaHeight + _barMaxHeight * (1 - _guideLinePercent / 100);

    return SizedBox(
      height: _percentAreaHeight + _barMaxHeight + _labelAreaHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: guideLineTop,
            child: const _DashedGuideLine(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                if (i > 0) const SizedBox(width: _groupGap),
                _MetricGroup(metric: metrics[i]),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricGroup extends StatelessWidget {
  const _MetricGroup({required this.metric});

  final RefreshResultMetricPair metric;

  Color get _afterColor {
    if (!metric.highlightAfter) {
      return AppColors.gray700;
    }
    return AppColors.primary500;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height:
              RefreshResultDetailMetricBars._barMaxHeight +
              RefreshResultDetailMetricBars._percentAreaHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _BarColumn(
                percent: metric.beforePercent,
                barColor: AppColors.gray200,
                isAfter: false,
              ),
              const SizedBox(width: RefreshResultDetailMetricBars._pairGap),
              _BarColumn(
                percent: metric.afterPercent,
                barColor: _afterColor,
                isAfter: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        AppText(
          metric.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyXs.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  const _BarColumn({
    required this.percent,
    required this.barColor,
    required this.isAfter,
  });

  final double percent;
  final Color barColor;
  final bool isAfter;

  @override
  Widget build(BuildContext context) {
    final maxHeight = RefreshResultDetailMetricBars._barMaxHeight;
    final barHeight = maxHeight * (percent / 100).clamp(0, 1);
    final percentText = _formatPercent(percent);

    return SizedBox(
      width: RefreshResultDetailMetricBars._barWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: RefreshResultDetailMetricBars._percentAreaHeight,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppText(
                  percentText,
                  maxLines: 1,
                  style: AppTextStyles.labelM.copyWith(
                    color: isAfter ? AppColors.gray900 : AppColors.gray500,
                    fontWeight: isAfter ? FontWeight.w700 : FontWeight.w400,
                    fontSize: 15,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: RefreshResultDetailMetricBars._barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(
                barHeight <= 0
                    ? 0
                    : (RefreshResultDetailMetricBars._barWidth / 2)
                          .clamp(0, barHeight / 2)
                          .toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPercent(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}%';
    }
    return '${value.toStringAsFixed(1)}%';
  }
}

class _DashedGuideLine extends StatelessWidget {
  const _DashedGuideLine();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(
        color: AppColors.gray300.withValues(alpha: 0.85),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 3.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.75;

    var startX = 0.0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
