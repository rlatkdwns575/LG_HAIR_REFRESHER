import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/refresh_mode_detail.dart';

/// 리프레시 상세 — 총 소요 시간 + 단계별 타임라인 (Figma 833:14941).
class RefreshDetailTimeline extends StatelessWidget {
  const RefreshDetailTimeline({
    required this.totalDurationLabel,
    required this.steps,
    super.key,
  });

  final String totalDurationLabel;
  final List<RefreshModeDetailStep> steps;

  static const double _dotSize = 10;
  static const double _lineWidth = 1;
  static const double _railWidth = 22;
  static const double _textGap = 18;
  static const Color _timelineLineColor = Color(0xFFE6EAF0);
  static const double _dotTopPadding = 8;
  static const double _dotCenterYOffset = _dotTopPadding + _dotSize / 2;
  static const double _lineEndExtension = 84;
  static const double _stepContentHeight = 54;

  static const double _contentIndent = _railWidth + _textGap;

  static double _lastDotCenterY(int stepCount) {
    if (stepCount <= 1) {
      return _dotCenterYOffset;
    }
    return _dotCenterYOffset +
        (stepCount - 1) * (_stepContentHeight + AppSpacing.lg);
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: _contentIndent),
              child: Text(
                totalDurationLabel,
                style: AppTextStyles.labelL.copyWith(
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: (_railWidth - _lineWidth) / 2,
                  top: _dotCenterYOffset - _lineEndExtension,
                  height:
                      (_lastDotCenterY(steps.length) - _dotCenterYOffset) +
                      (_lineEndExtension * 2),
                  child: Container(
                    width: _lineWidth,
                    color: _timelineLineColor,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      _TimelineStepRow(
                        step: steps[i],
                        isLast: i == steps.length - 1,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStepRow extends StatelessWidget {
  const _TimelineStepRow({required this.step, required this.isLast});

  final RefreshModeDetailStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: RefreshDetailTimeline._railWidth,
            child: Padding(
              padding: const EdgeInsets.only(
                top: RefreshDetailTimeline._dotTopPadding,
              ),
              child: Center(
                child: Container(
                  width: RefreshDetailTimeline._dotSize,
                  height: RefreshDetailTimeline._dotSize,
                  decoration: const BoxDecoration(
                    color: AppColors.primary500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: RefreshDetailTimeline._textGap),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.titleM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: '${step.durationLabel} ',
                        style: const TextStyle(color: AppColors.primary500),
                      ),
                      TextSpan(
                        text: step.title,
                        style: const TextStyle(color: AppColors.gray900),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  step.description,
                  style: AppTextStyles.bodyM1.copyWith(
                    color: AppColors.gray500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
