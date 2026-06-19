import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';
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

  static const double _dotSize = 8;
  static const double _lineWidth = 1;
  static const double _railWidth = 22;
  static const double _textGap = 7;
  static const Color _timelineLineColor = Color(0xFFE6EAF0);
  static const double _dotTopPadding = 6;
  static const double _dotCenterYOffset = _dotTopPadding + _dotSize / 2;

  /// Figma: 총소요시간 ↔ 단계 목록 간격 20px.
  static const double _durationToStepsGap = 20;

  /// Figma: 단계 간 세로 간격 28px.
  static const double _stepGap = 28;

  /// 연결선 높이 계산용 — 제목·설명 1줄 기준 행 높이.
  static const double _stepRowHeight = 48;

  /// 첫·마지막 점 바깥으로 연장하는 세로선 길이.
  static const double _lineEndExtension = 63;

  static const double _contentIndent = _railWidth + _textGap;

  static double _lastDotCenterY(int stepCount) {
    if (stepCount <= 1) {
      return _dotCenterYOffset;
    }
    return _dotCenterYOffset + (stepCount - 1) * (_stepRowHeight + _stepGap);
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: _contentIndent),
          child: AppText(
            totalDurationLabel,
            style: AppTextStyles.labelM.copyWith(
              color: AppColors.gray500,
              height: 16 / 12,
            ),
          ),
        ),
        const SizedBox(height: _durationToStepsGap),
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (steps.length > 1)
              Positioned(
                left: (_railWidth - _lineWidth) / 2,
                top: _dotCenterYOffset - _lineEndExtension,
                height:
                    (_lastDotCenterY(steps.length) - _dotCenterYOffset) +
                    (_lineEndExtension * 2),
                child: Container(width: _lineWidth, color: _timelineLineColor),
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
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : RefreshDetailTimeline._stepGap,
      ),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.titleM.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '${step.durationLabel} '.softWrapWords(),
                      style: const TextStyle(color: AppColors.primary700),
                    ),
                    TextSpan(
                      text: step.title.softWrapWords(),
                      style: const TextStyle(color: AppColors.gray900),
                    ),
                  ],
                ),
              ),
              if (step.description != null && step.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  step.description!,
                  style: AppTextStyles.labelS.copyWith(
                    color: AppColors.gray700,
                    height: 14 / 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
