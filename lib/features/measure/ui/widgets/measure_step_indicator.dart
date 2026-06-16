import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 헤어 상태 진단 진입 단계 (모발 유형 1 + 준비 3).
class MeasureIntroStepIndicator {
  const MeasureIntroStepIndicator._();

  static const totalSteps = 4;
  static const hairProfileStepIndex = 0;
  static const prepareStepOffset = 1;
}

class MeasureStepIndicator extends StatelessWidget {
  const MeasureStepIndicator({
    required this.currentStep,
    this.totalSteps = 3,
    super.key,
  });

  final int currentStep;
  final int totalSteps;

  static const double _dotSize = 6;
  static const double _dotGap = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: Align(
        alignment: Alignment.bottomCenter, // 하단 기준으로 정렬
        child: Padding(
          padding: const EdgeInsets.only(bottom: 9), // 아래에 정확히 9만큼 간격 추가
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < totalSteps; index++) ...[
                if (index > 0) const SizedBox(width: _dotGap),
                _StepDot(isActive: index == currentStep),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MeasureStepIndicator._dotSize,
      height: MeasureStepIndicator._dotSize,
      decoration: BoxDecoration(
        color: isActive ? AppColors.gray700 : AppColors.gray300,
        shape: BoxShape.circle,
      ),
    );
  }
}
