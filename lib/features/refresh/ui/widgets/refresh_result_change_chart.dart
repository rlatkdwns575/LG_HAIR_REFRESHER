import 'package:flutter/material.dart';

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

  static double chartHeightForRowCount(int rowCount) => _rowHeight * rowCount;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxChartWidth),
        child: Row(
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _chartHorizontalInset,
                    ),
                    child: Row(
                      children: [
                        for (
                          var i = 0;
                          i < RefreshPollutionLevel.axisLabels.length;
                          i++
                        )
                          Expanded(
                            child: Text(
                              RefreshPollutionLevel.axisLabels[i],
                              textAlign: i == 0
                                  ? TextAlign.left
                                  : i ==
                                        RefreshPollutionLevel
                                                .axisLabels
                                                .length -
                                            1
                                  ? TextAlign.right
                                  : TextAlign.center,
                              style: AppTextStyles.labelS.copyWith(
                                color: AppColors.gray500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
        child: Text(
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
  static const Color _startDotColor = AppColors.gray300;
  static const Color _endDotColor = AppColors.primary500;

  @override
  void paint(Canvas canvas, Size size) {
    final chartLeft = horizontalInset;
    final chartWidth = size.width - horizontalInset * 2;
    final gridBottom = size.height;

    for (var i = 0; i <= _gridDivisions; i++) {
      final fraction = i / _gridDivisions;
      final x = chartLeft + chartWidth * fraction;
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
      final startX = chartLeft + chartWidth * change.beforeLevel.axisFraction;
      final endX = chartLeft + chartWidth * change.afterLevel.axisFraction;
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
