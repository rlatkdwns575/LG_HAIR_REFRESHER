import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_pollution_level.dart';
import '../../data/model/refresh_result_change.dart';

/// 먼지/냄새 리프레시 전후 상태 변화 그래프.
class RefreshResultChangeChart extends StatelessWidget {
  const RefreshResultChangeChart({
    required this.dustChange,
    required this.odorChange,
    super.key,
  });

  final RefreshResultChange dustChange;
  final RefreshResultChange odorChange;

  static const maxChartWidth = 300.0;
  static const _labelColumnWidth = 36.0;
  static const _rowHeight = 48.0;
  static const _chartHorizontalInset = 6.0;
  static const _axisLabelGap = 12.0;
  static const _legendGap = 30.0;
  static const _legendItemGap = 24.0;

  static const Color beforeLegendColor = AppColors.gray300;
  static const Color afterLegendColor = AppColors.primary500;

  static double chartHeightForRowCount(int rowCount) => _rowHeight * rowCount;

  /// 차트 [CustomPaint]와 X축 라벨이 동일한 x 좌표를 쓰도록 공유합니다.
  static double gridLineX(
    double fraction,
    double totalWidth, {
    double horizontalInset = _chartHorizontalInset,
  }) {
    final chartWidth = totalWidth - horizontalInset * 2;
    return horizontalInset + chartWidth * fraction;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxChartWidth),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _labelColumnWidth,
                  child: Column(
                    children: [
                      _RowLabel(label: dustChange.label),
                      _RowLabel(label: odorChange.label),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: chartHeightForRowCount(2),
                        child: CustomPaint(
                          painter: _RefreshResultChangeChartPainter(
                            changes: [dustChange, odorChange],
                            rowHeight: _rowHeight,
                            horizontalInset: _chartHorizontalInset,
                          ),
                        ),
                      ),
                      const SizedBox(height: _axisLabelGap),
                      const _ChartAxisLabels(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: _legendGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _ChartLegendItem(color: beforeLegendColor, label: '리프레시 이전'),
                SizedBox(width: _legendItemGap),
                _ChartLegendItem(color: afterLegendColor, label: '리프레시 이후'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartAxisLabels extends StatelessWidget {
  const _ChartAxisLabels();

  static const _rowHeight = 16.0;

  static final TextStyle _labelStyle = AppTextStyles.labelS.copyWith(
    color: AppColors.gray500,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final textDirection = Directionality.of(context);
        final labels = <Widget>[];

        for (final level in RefreshPollutionLevel.values) {
          final x = RefreshResultChangeChart.gridLineX(
            level.axisFraction,
            totalWidth,
          );
          final painter = TextPainter(
            text: TextSpan(text: level.label, style: _labelStyle),
            textAlign: TextAlign.center,
            textDirection: textDirection,
          )..layout();

          labels.add(
            Positioned(
              left: x - painter.width / 2,
              top: 0,
              child: AppText(level.label, style: _labelStyle),
            ),
          );
        }

        return SizedBox(
          height: _rowHeight,
          child: Stack(clipBehavior: Clip.none, children: labels),
        );
      },
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  static const _dotSize = 10.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        AppText(
          label,
          style: AppTextStyles.labelS.copyWith(
            color: AppColors.gray500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RefreshResultChangeChart._rowHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: AppText(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.gray700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _RefreshResultChangeChartPainter extends CustomPainter {
  _RefreshResultChangeChartPainter({
    required this.changes,
    required this.rowHeight,
    required this.horizontalInset,
  });

  final List<RefreshResultChange> changes;
  final double rowHeight;
  final double horizontalInset;

  /// 메인 단계(4) 사이 보조 구분선 포함 — 총 7개 세로선.
  static const _gridDivisions = 6;

  static const _barHeight = 14.0;

  static final Color _barGradientStart = AppColors.gray300.withValues(
    alpha: 0.35,
  );
  static final Color _barGradientEnd = AppColors.primary500.withValues(
    alpha: 0.4,
  );
  static const Color _startDotColor =
      RefreshResultChangeChart.beforeLegendColor;
  static const Color _endDotColor = RefreshResultChangeChart.afterLegendColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridBottom = size.height;

    for (var i = 0; i <= _gridDivisions; i++) {
      final fraction = i / _gridDivisions;
      final x = RefreshResultChangeChart.gridLineX(
        fraction,
        size.width,
        horizontalInset: horizontalInset,
      );
      final isMajor = i.isEven;
      final gridPaint = Paint()
        ..color = isMajor ? AppColors.gray200 : AppColors.gray100
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, 0), Offset(x, gridBottom), gridPaint);
    }

    final dotRadius = _barHeight / 2;

    for (var row = 0; row < changes.length; row++) {
      final change = changes[row];
      final centerY = rowHeight * row + rowHeight / 2;
      final startX = RefreshResultChangeChart.gridLineX(
        change.beforeAxisFraction,
        size.width,
        horizontalInset: horizontalInset,
      );
      final endX = RefreshResultChangeChart.gridLineX(
        change.afterAxisFraction,
        size.width,
        horizontalInset: horizontalInset,
      );
      final left = startX < endX ? startX : endX;
      final right = startX < endX ? endX : startX;

      if ((right - left) > 0) {
        final lineRect = Rect.fromCenter(
          center: Offset((left + right) / 2, centerY),
          width: right - left,
          height: _barHeight,
        );
        final linePaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_barGradientStart, _barGradientEnd],
          ).createShader(lineRect);
        canvas.drawRRect(
          RRect.fromRectAndRadius(lineRect, Radius.circular(dotRadius)),
          linePaint,
        );
      }

      canvas.drawCircle(
        Offset(startX, centerY),
        dotRadius,
        Paint()..color = _startDotColor,
      );
      canvas.drawCircle(
        Offset(endX, centerY),
        dotRadius,
        Paint()..color = _endDotColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RefreshResultChangeChartPainter oldDelegate) {
    return oldDelegate.changes != changes ||
        oldDelegate.horizontalInset != horizontalInset ||
        oldDelegate.rowHeight != rowHeight;
  }
}
