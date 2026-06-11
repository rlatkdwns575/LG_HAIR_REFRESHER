import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_progress_session.dart';

/// Figma `Frame 4907` — 단계 타임라인 (점 · 연결선 · 케어명 · 시간).
class RefreshProgressStepStrip extends StatelessWidget {
  const RefreshProgressStepStrip({
    required this.steps,
    required this.activeIndex,
    this.dimmed = false,
    super.key,
  });

  final List<RefreshProgressStep> steps;
  final int activeIndex;
  final bool dimmed;

  static const double _dotSize = 8;
  static const double _columnWidth = 92;
  static const double _columnGap = 24;
  static const double _dotRowHeight = _dotSize;
  static const double _lineHorizontalExtension = 40;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final stripWidth =
        steps.length * _columnWidth + (steps.length - 1) * _columnGap;

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: SizedBox(
        width: stripWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (steps.length > 1)
              Positioned(
                left: _columnWidth / 2 - _lineHorizontalExtension,
                right: _columnWidth / 2 - _lineHorizontalExtension,
                top: (_dotRowHeight - 1) / 2,
                child: Container(height: 1, color: AppColors.gray200),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < steps.length; i++)
                  _StepColumn(
                    step: steps[i],
                    isActive: i == activeIndex,
                    width: _columnWidth,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepColumn extends StatelessWidget {
  const _StepColumn({
    required this.step,
    required this.isActive,
    required this.width,
  });

  final RefreshProgressStep step;
  final bool isActive;
  final double width;

  @override
  Widget build(BuildContext context) {
    final intensityColor = isActive ? AppColors.primary400 : AppColors.gray500;
    final dotSize = isActive ? 8.0 : 6.0;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            height: RefreshProgressStepStrip._dotRowHeight,
            child: Center(
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary500 : AppColors.primary300,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            step.stepTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyL.copyWith(
              color: isActive ? AppColors.gray800 : AppColors.gray500,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            step.durationLabel,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyM1.copyWith(
              color: isActive ? intensityColor : AppColors.gray500,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
