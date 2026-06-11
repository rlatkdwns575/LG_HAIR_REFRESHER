import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Figma `graph` + `Frame 4956` — 160px 링 · 진행률 · 잔여 시간.
///
/// [MeasureProgressRing]과 동일하게 CustomPaint 기반이며,
/// SweepGradient와 1초 선형 보간으로 부드럽게 채워집니다.
class RefreshProgressRing extends StatelessWidget {
  const RefreshProgressRing({
    required this.progress,
    required this.remainingLabel,
    this.dimmed = false,
    super.key,
  });

  final double progress;
  final String remainingLabel;
  final bool dimmed;

  static const _ringSize = 160.0;
  static const _strokeWidth = 12.0;
  static const Duration _animationDuration = Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0.0, 1.0);

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: target),
        duration: dimmed ? Duration.zero : _animationDuration,
        curve: Curves.linear,
        builder: (context, animatedProgress, _) {
          final displayPercent = (animatedProgress * 100).round();

          return SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: CustomPaint(
              painter: _RefreshRingPainter(
                progress: animatedProgress,
                strokeWidth: _strokeWidth,
                trackColor: AppColors.gray100,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$displayPercent%',
                      style: AppTextStyles.headlineL.copyWith(
                        color: AppColors.primary400,
                        fontSize: 36,
                        height: 36 / 36,
                        letterSpacing: -0.72,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      remainingLabel,
                      style: AppTextStyles.bodyM1.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RefreshRingPainter extends CustomPainter {
  _RefreshRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;

  static const _gradientColors = [
    AppColors.primary300,
    AppColors.primary400,
    AppColors.primary500,
  ];

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

    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: _gradientColors,
      stops: const [0.0, 0.55, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(_RefreshRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
