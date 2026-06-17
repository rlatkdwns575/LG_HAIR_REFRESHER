import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class _NeedBarItem {
  const _NeedBarItem({
    required this.label,
    required this.percent,
    required this.emphasized,
  });

  final String label;
  final int percent;
  final bool emphasized;
}

/// 냄새/먼지/모발 케어 필요도 막대 + 권장기준 세로선 (Figma 동일 길이·굵기).
class MeasureResultDetailNeedBars extends StatelessWidget {
  const MeasureResultDetailNeedBars({
    required this.odorPercent,
    required this.dustPercent,
    required this.hairPercent,
    required this.thresholdPercent,
    super.key,
  });

  final int odorPercent;
  final int dustPercent;
  final int hairPercent;
  final int thresholdPercent;

  static const double _barHeight = 20;
  static const double _rowHeight = 34;
  static const double _labelWidth = 116;
  static const double _percentWidth = 44;
  static const double _barRadius = 10;
  static const double _thresholdLabelTop = 24;
  static const double _barMaxRatio = 0.64;
  static const double _horizontalInset = 14;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NeedBarItem(
        label: '냄새 케어 필요도',
        percent: odorPercent,
        emphasized: odorPercent >= thresholdPercent,
      ),
      _NeedBarItem(
        label: '먼지 케어 필요도',
        percent: dustPercent,
        emphasized: dustPercent >= thresholdPercent,
      ),
      _NeedBarItem(
        label: '모발 컨디션 영향도',
        percent: hairPercent,
        emphasized: false,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MeasureResultDetailNeedBars._horizontalInset,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth =
              constraints.maxWidth - _labelWidth - _percentWidth;
          final barWidth = availableWidth * _barMaxRatio;
          final barStartX = _labelWidth + (availableWidth - barWidth) / 2;
          final thresholdLeft = barStartX + barWidth * (thresholdPercent / 100);

          return SizedBox(
            height: _thresholdLabelTop + items.length * _rowHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    const SizedBox(height: _thresholdLabelTop),
                    for (final item in items)
                      _NeedBarRow(item: item, barWidth: barWidth),
                  ],
                ),
                Positioned(
                  left: thresholdLeft,
                  top: _thresholdLabelTop,
                  bottom: 0,
                  child: CustomPaint(
                    size: const Size(1, double.infinity),
                    painter: _DashedVerticalLinePainter(),
                  ),
                ),
                Positioned(
                  left: thresholdLeft - 22,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: AppText(
                      '권장기준',
                      style: AppTextStyles.labelS.copyWith(
                        color: AppColors.gray600,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NeedBarRow extends StatelessWidget {
  const _NeedBarRow({required this.item, required this.barWidth});

  final _NeedBarItem item;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final fillWidth = barWidth * (item.percent.clamp(0, 100) / 100);
    final fillColor = item.emphasized ? AppColors.orange600 : AppColors.gray400;

    return SizedBox(
      height: MeasureResultDetailNeedBars._rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: MeasureResultDetailNeedBars._labelWidth,
            child: AppText(
              item.label,
              textAlign: TextAlign.left,
              style: AppTextStyles.labelS.copyWith(
                color: AppColors.gray800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: barWidth,
                height: MeasureResultDetailNeedBars._barHeight,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      width: barWidth,
                      height: MeasureResultDetailNeedBars._barHeight,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(
                          MeasureResultDetailNeedBars._barRadius,
                        ),
                      ),
                    ),
                    Container(
                      width: fillWidth,
                      height: MeasureResultDetailNeedBars._barHeight,
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(
                          MeasureResultDetailNeedBars._barRadius,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: MeasureResultDetailNeedBars._percentWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                '${item.percent}%',
                style: AppTextStyles.labelS.copyWith(
                  color: item.emphasized
                      ? AppColors.gray900
                      : AppColors.gray600,
                  fontSize: 13,
                  fontWeight: item.emphasized
                      ? FontWeight.w800
                      : FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedVerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray400
      ..strokeWidth = 1;

    const dash = 3.0;
    const gap = 2.0;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
