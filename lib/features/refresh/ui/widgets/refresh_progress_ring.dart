import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Figma `graph` + `Frame 4956` — 160px 링 · 진행률 · 잔여 시간.
///
/// [MeasureProgressRing]과 동일하게 진행률에 따라 연한 색 → 진한 색으로 보간한
/// 단일 호를 그립니다. 일시정지([dimmed]) 시 회색으로 표시합니다.
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
  static const Duration _animationDuration = Duration(milliseconds: 900);

  static const Color _activeStartColor = AppColors.primary300;
  static const Color _activeEndColor = AppColors.primary500;
  static const Color _pausedStartColor = AppColors.gray300;
  static const Color _pausedEndColor = AppColors.gray500;

  @override
  Widget build(BuildContext context) {
    final target = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: target),
      duration: dimmed ? Duration.zero : _animationDuration,
      curve: Curves.linear,
      builder: (context, animatedProgress, _) {
        final displayPercent = (animatedProgress * 100).round();
        final startColor = dimmed ? _pausedStartColor : _activeStartColor;
        final endColor = dimmed ? _pausedEndColor : _activeEndColor;
        final progressColor =
            Color.lerp(startColor, endColor, animatedProgress) ?? endColor;

        return SizedBox(
          width: _ringSize,
          height: _ringSize,
          child: CustomPaint(
            painter: _RefreshRingPainter(
              progress: animatedProgress,
              strokeWidth: _strokeWidth,
              trackColor: AppColors.gray100,
              progressColor: progressColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.translate(
                    offset: const Offset(6, 0),
                    child: AppText(
                      '$displayPercent%',
                      style: AppTextStyles.headlineL.copyWith(
                        color: dimmed
                            ? AppColors.gray500
                            : AppColors.primary400,
                        fontSize: 36,
                        height: 36 / 36,
                        letterSpacing: -0.72,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppText(
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
    );
  }
}

class _RefreshRingPainter extends CustomPainter {
  _RefreshRingPainter({
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

    final tipAngle = startAngle + sweep;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(tip, strokeWidth * 0.7, Paint()..color = AppColors.gray0);
    canvas.drawCircle(tip, strokeWidth * 0.42, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(_RefreshRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
