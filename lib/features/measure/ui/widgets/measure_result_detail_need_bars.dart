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

/// 냄새/먼지/모발 케어 필요도 막대 + 권장기준 세로선 (Figma 40000056:19052).
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

  /// Figma — 막대 트랙 높이 (고정).
  static const double barHeight = 20;

  /// Figma 40000056:19053/19066 — 행 간격.
  static const double rowGap = 18;

  /// Figma 40000056:19052 — 라벨 | 막대 | % 열 간격.
  static const double columnGap = 20;

  /// Figma — 라벨 열 너비.
  static const double labelWidth = 82;

  static const double _barRadius = 10;
  static const double _horizontalInset = 15;

  /// Figma 40000080:17709 — 배지(20) + 막대까지 간격(9).
  static const double _thresholdOverlayHeight = 29;

  static const _labelStyle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w400,
    color: AppColors.gray900,
  );

  @override
  Widget build(BuildContext context) {
    final items = [
      _NeedBarItem(
        label: '냄새 감지 수준',
        percent: odorPercent,
        emphasized: odorPercent >= thresholdPercent,
      ),
      _NeedBarItem(
        label: '먼지 감지 수준',
        percent: dustPercent,
        emphasized: dustPercent >= thresholdPercent,
      ),
      _NeedBarItem(label: '모발 컨디션 수준', percent: hairPercent, emphasized: false),
    ];

    final chartBodyHeight =
        items.length * barHeight + (items.length - 1) * rowGap;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MeasureResultDetailNeedBars._horizontalInset,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: _thresholdOverlayHeight + chartBodyHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: labelWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: _thresholdOverlayHeight,
                    ),
                    child: _LabelColumn(items: items),
                  ),
                ),
                const SizedBox(width: columnGap),
                Expanded(
                  child: _BarChartArea(
                    items: items,
                    thresholdPercent: thresholdPercent,
                    chartBodyHeight: chartBodyHeight,
                  ),
                ),
                const SizedBox(width: columnGap),
                Padding(
                  padding: const EdgeInsets.only(top: _thresholdOverlayHeight),
                  child: _PercentColumn(items: items),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LabelColumn extends StatelessWidget {
  const _LabelColumn({required this.items});

  final List<_NeedBarItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: MeasureResultDetailNeedBars.rowGap),
          SizedBox(
            height: MeasureResultDetailNeedBars.barHeight,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppText(
                items[i].label,
                style: MeasureResultDetailNeedBars._labelStyle,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PercentColumn extends StatelessWidget {
  const _PercentColumn({required this.items});

  final List<_NeedBarItem> items;

  TextStyle _percentStyle(_NeedBarItem item) {
    return MeasureResultDetailNeedBars._labelStyle.copyWith(
      color: item.emphasized ? AppColors.gray900 : AppColors.gray600,
      fontWeight: item.emphasized ? FontWeight.w700 : FontWeight.w400,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: MeasureResultDetailNeedBars.rowGap),
          SizedBox(
            height: MeasureResultDetailNeedBars.barHeight,
            child: Align(
              alignment: Alignment.centerRight,
              child: AppText(
                '${items[i].percent}%',
                style: _percentStyle(items[i]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BarChartArea extends StatelessWidget {
  const _BarChartArea({
    required this.items,
    required this.thresholdPercent,
    required this.chartBodyHeight,
  });

  final List<_NeedBarItem> items;
  final int thresholdPercent;
  final double chartBodyHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final thresholdLeft = barWidth * (thresholdPercent / 100);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: MeasureResultDetailNeedBars._thresholdOverlayHeight,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0)
                      const SizedBox(
                        height: MeasureResultDetailNeedBars.rowGap,
                      ),
                    _HorizontalBar(item: items[i], barWidth: barWidth),
                  ],
                ],
              ),
            ),
            Positioned(
              left: thresholdLeft - 0.5,
              top: MeasureResultDetailNeedBars._thresholdOverlayHeight,
              height: chartBodyHeight,
              child: CustomPaint(
                size: Size(1, chartBodyHeight),
                painter: _DashedVerticalLinePainter(),
              ),
            ),
            Positioned(
              left: thresholdLeft,
              top: 0,
              child: const FractionalTranslation(
                translation: Offset(-0.5, 0),
                child: _RecommendedThresholdBadge(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({required this.item, required this.barWidth});

  final _NeedBarItem item;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final fillWidth = barWidth * (item.percent.clamp(0, 100) / 100);
    final fillColor = item.emphasized ? AppColors.orange600 : AppColors.gray400;

    return SizedBox(
      height: MeasureResultDetailNeedBars.barHeight,
      width: barWidth,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            width: barWidth,
            height: MeasureResultDetailNeedBars.barHeight,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(
                MeasureResultDetailNeedBars._barRadius,
              ),
            ),
          ),
          Container(
            width: fillWidth,
            height: MeasureResultDetailNeedBars.barHeight,
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(
                MeasureResultDetailNeedBars._barRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Figma 40000080:17709 — 권장기준 툴팁 배지 + 아래 포인터.
class _RecommendedThresholdBadge extends StatelessWidget {
  const _RecommendedThresholdBadge();

  static const _badgeTextStyle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 8,
    height: 1,
    fontWeight: FontWeight.w500,
    color: AppColors.gray500,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(2),
          ),
          child: const AppText('권장기준', style: _badgeTextStyle),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: CustomPaint(
            size: const Size(6, 6),
            painter: _ThresholdPointerPainter(),
          ),
        ),
      ],
    );
  }
}

class _ThresholdPointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.gray100);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Figma Vector 949 (40000056:19065) — stroke #B3BAC4, dasharray 2 2, square cap.
class _DashedVerticalLinePainter extends CustomPainter {
  static const double _dashLength = 2;
  static const double _dashGap = 2;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray400
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.square;

    const x = 0.5;
    var y = 0.0;
    while (y < size.height) {
      final end = (y + _dashLength).clamp(0.0, size.height);
      if (end > y) {
        canvas.drawLine(Offset(x, y), Offset(x, end), paint);
      }
      y += _dashLength + _dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
