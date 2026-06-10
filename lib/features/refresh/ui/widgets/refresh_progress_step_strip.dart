import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_progress_session.dart';

/// Figma `Frame 4907` — 단계 타임라인 (점 · 케어명 · 시간 · 강도).
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

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) const SizedBox(width: 30),
            _StepColumn(step: steps[i], isActive: i == activeIndex),
          ],
        ],
      ),
    );
  }
}

class _StepColumn extends StatelessWidget {
  const _StepColumn({required this.step, required this.isActive});

  final RefreshProgressStep step;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final titleColor = isActive ? AppColors.gray800 : AppColors.gray500;
    final metaColor = isActive ? AppColors.gray800 : AppColors.gray500;
    final intensityColor = isActive ? AppColors.primary400 : AppColors.gray500;

    return SizedBox(
      width: 66,
      child: Column(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary500 : AppColors.primary300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyM1.copyWith(color: titleColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                step.durationLabel,
                style: AppTextStyles.bodyXs.copyWith(color: metaColor),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                step.intensityLabel,
                style: AppTextStyles.bodyXs.copyWith(color: intensityColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
