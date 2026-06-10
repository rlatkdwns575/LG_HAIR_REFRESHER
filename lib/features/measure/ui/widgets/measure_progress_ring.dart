import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 진단 진행률을 원형 그래프로 보여주는 위젯.
///
/// 중앙에 퍼센트, 진행 끝점에 손잡이(knob)를 그립니다.
class MeasureProgressRing extends StatelessWidget {
  const MeasureProgressRing({
    required this.progress,
    this.size = 220,
    this.strokeWidth = 16,
    this.progressColor = AppColors.primary500,
    super.key,
  });

  /// 0.0 ~ 1.0
  final double progress;
  final double size;
  final double strokeWidth;

  /// 진행률 100%일 때의 색. 낮을수록 [_startColor]에 가까운 파스텔로 연해집니다.
  final Color progressColor;

  /// 진행률 0%에 가까울 때의 연한 파스텔 색.
  static const Color _startColor = AppColors.primary300;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    final percent = (value * 100).round();
    // 진행률이 올라갈수록 연한 색 → 진한 색으로 보간.
    final color =
        Color.lerp(_startColor, progressColor, value) ?? progressColor;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: value,
          strokeWidth: strokeWidth,
          trackColor: AppColors.gray200,
          progressColor: color,
        ),
        child: Center(
          // '%' 글자 때문에 시각적으로 왼쪽으로 치우쳐 보여 살짝 오른쪽으로 보정.
          child: Transform.translate(
            offset: const Offset(5, 0),
            child: Text(
              '$percent%',
              style: AppTextStyles.headlineL.copyWith(
                fontSize: 40,
                color: AppColors.gray900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    const startAngle = -math.pi / 2;
    final sweep = progress * 2 * math.pi;
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);

    // 진행 끝점 손잡이 (흰 배경 + 진행색 점)
    final tipAngle = startAngle + sweep;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(tip, strokeWidth * 0.7, Paint()..color = AppColors.gray0);
    canvas.drawCircle(tip, strokeWidth * 0.42, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
