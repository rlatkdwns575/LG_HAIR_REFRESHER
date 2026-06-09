import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../data/model/measure_prepare_step.dart';
import '../../data/model/measure_prepare_step_copy.dart';
import 'measure_prepare_image_area.dart';
import 'measure_prepare_instruction.dart';

class MeasurePrepareBody extends StatelessWidget {
  const MeasurePrepareBody({required this.step, super.key});

  final MeasurePrepareStep step;

  static const double _horizontalPadding = 15;
  static const double _contentTopGap = 8;

  @override
  Widget build(BuildContext context) {
    final copy = MeasurePrepareStepCopy.forStep(step);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: _contentTopGap),
          const MeasurePrepareImageArea(),
          const SizedBox(height: AppSpacing.xl),
          // AnimatedSwitcher를 추가해 문구가 바뀔 때 디졸브 효과를 줌
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: MeasurePrepareInstruction(
              key: ValueKey(step), // step 변경을 감지하기 위한 고유 키
              title: copy.title,
              subtitle: copy.subtitle,
            ),
          ),
        ],
      ),
    );
  }
}
