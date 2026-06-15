import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 리프레시 필요도 반원 게이지 (Figma Frame 2085668879).
class MeasureResultDetailNeedGauge extends StatelessWidget {
  const MeasureResultDetailNeedGauge({
    required this.percent,
    required this.thresholdPercent,
    super.key,
  });

  final int percent;
  final int thresholdPercent;

  static const double _size = 88;
  static const double _strokeWidth = 8;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size * 0.62,
      child: CustomPaint(
        painter: _NeedGaugePainter(
          percent: percent.clamp(0, 100) / 100,
          thresholdPercent: thresholdPercent.clamp(0, 100) / 100,
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '$percent%',
              style: AppTextStyles.titleS.copyWith(
                color: AppColors.gray900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NeedGaugePainter extends CustomPainter {
  _NeedGaugePainter({required this.percent, required this.thresholdPercent});

  final double percent;
  final double thresholdPercent;

  static const double _startAngle = math.pi;
  static const double _sweepRange = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius =
        size.width / 2 - MeasureResultDetailNeedGauge._strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.gray200
      ..style = PaintingStyle.stroke
      ..strokeWidth = MeasureResultDetailNeedGauge._strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, _startAngle, _sweepRange, false, trackPaint);

    final progressColor = Color.lerp(
      AppColors.primary300,
      AppColors.orange600,
      percent,
    )!;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = MeasureResultDetailNeedGauge._strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      _startAngle,
      _sweepRange * percent,
      false,
      progressPaint,
    );

    _drawThresholdLine(canvas, center, radius);
  }

  void _drawThresholdLine(Canvas canvas, Offset center, double radius) {
    final angle = _startAngle + _sweepRange * thresholdPercent;
    final inner =
        center +
        Offset(math.cos(angle) * (radius - 6), math.sin(angle) * (radius - 6));
    final outer =
        center +
        Offset(math.cos(angle) * (radius + 6), math.sin(angle) * (radius + 6));

    final dashPaint = Paint()
      ..color = AppColors.gray500
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashLength = 3.0;
    const gapLength = 2.0;
    final total = (inner - outer).distance;
    final direction = (outer - inner) / total;
    var drawn = 0.0;
    var drawing = true;

    while (drawn < total) {
      final segment = drawing ? dashLength : gapLength;
      final end = drawn + segment;
      if (drawing) {
        canvas.drawLine(
          inner + direction * drawn,
          inner + direction * end.clamp(0, total),
          dashPaint,
        );
      }
      drawn = end;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _NeedGaugePainter oldDelegate) {
    return oldDelegate.percent != percent ||
        oldDelegate.thresholdPercent != thresholdPercent;
  }
}
