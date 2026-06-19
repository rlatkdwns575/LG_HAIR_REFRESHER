import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/model/refresh_mode_detail.dart';

/// Figma 40000026:25149 — 타임라인 영역 330×250, 화면 가운데 배치.
const _timelineWidth = 330.0;
const _timelineHeight = 250.0;

/// Figma 40000026:25152 — 본문 시작 x=60, 너비 200.
const _contentLeft = 60.0;
const _contentWidth = 200.0;

/// Figma 40000026:25153 — 총소요시간 세로 패딩.
const _durationVerticalPadding = 10.0;

/// Figma 40000026:25152 — 콘텐츠 세로 중심 = 50% − 34px.
const _contentCenterYOffset = 34.0;

const _lineLeft = 64.0;
const _lineWidth = 1.0;
const _dotSize = 8.0;
const _textGap = 7.0;

/// 단계 제목 텍스트 시작 x (= dot 8 + gap 7).
const _stepTextLeftInset = _dotSize + _textGap;
const _timelineLineColor = Color(0xFFE6EAF0);
const _dotTopPadding = 6.0;

/// Figma: 총소요시간 ↔ 단계 목록 간격 20px.
const _durationToStepsGap = 20.0;

/// Figma: 단계 간 세로 간격 28px.
const _stepGap = 28.0;

/// 리프레시 상세 — 총 소요 시간 + 단계별 타임라인 (Figma 40000026:25149).
class RefreshDetailTimeline extends StatelessWidget {
  const RefreshDetailTimeline({
    required this.totalDurationLabel,
    required this.steps,
    super.key,
  });

  final String totalDurationLabel;
  final List<RefreshModeDetailStep> steps;

  static double _timelineBlockHeight(int stepCount) {
    if (stepCount <= 1) {
      return _timelineHeight;
    }

    const durationBlock =
        _durationVerticalPadding * 2 + 16 + _durationToStepsGap;
    const stepRowHeight = 54.0;
    final stepsHeight = stepCount * stepRowHeight + (stepCount - 1) * _stepGap;

    return math.max(_timelineHeight, durationBlock + stepsHeight + 16);
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const SizedBox.shrink();
    }

    final blockHeight = _timelineBlockHeight(steps.length);
    final contentCenterY = blockHeight / 2 - _contentCenterYOffset;
    final contentAlignY = (contentCenterY / blockHeight) * 2 - 1;

    return Center(
      child: SizedBox(
        width: _timelineWidth,
        height: blockHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _lineLeft - _lineWidth / 2,
              top: 0,
              height: blockHeight,
              child: Container(width: _lineWidth, color: _timelineLineColor),
            ),
            Positioned(
              left: _contentLeft,
              top: 0,
              width: _contentWidth,
              height: blockHeight,
              child: Align(
                alignment: Alignment(-1, contentAlignY),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: _stepTextLeftInset,
                        top: _durationVerticalPadding,
                        bottom: _durationVerticalPadding,
                      ),
                      child: AppText(
                        totalDurationLabel,
                        textAlign: TextAlign.start,
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.gray500,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: _durationToStepsGap),
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
              ),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : _stepGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: _dotTopPadding),
            child: Container(
              width: _dotSize,
              height: _dotSize,
              decoration: const BoxDecoration(
                color: AppColors.primary500,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: _textGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.titleS.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 22 / 16,
                    ),
                    children: [
                      TextSpan(
                        text: step.durationLabel,
                        style: const TextStyle(color: AppColors.primary700),
                      ),
                      const TextSpan(text: ' '),
                      TextSpan(
                        text: step.title,
                        style: const TextStyle(color: AppColors.gray900),
                      ),
                    ],
                  ),
                ),
                if (step.description != null &&
                    step.description!.isNotEmpty) ...[
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
          ),
        ],
      ),
    );
  }
}
