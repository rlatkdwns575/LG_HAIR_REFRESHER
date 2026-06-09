import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import 'measure_prepare_image_area.dart';
import 'measure_prepare_instruction.dart';
import 'measure_skeleton_box.dart';
import 'measure_step_indicator.dart';

class MeasurePrepareSkeleton extends StatelessWidget {
  const MeasurePrepareSkeleton({super.key});

  static const double _horizontalPadding = 15;
  static const double _contentTopGap = 8;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MeasureStepIndicator(currentStep: 0),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: _contentTopGap),
                const SizedBox(
                  width: double.infinity,
                  child: MeasureSkeletonBox(
                    width: double.infinity,
                    height: MeasurePrepareImageArea.height,
                    borderRadius: MeasurePrepareImageArea.imageRadius,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const MeasurePrepareInstruction(title: '', isLoading: true),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            10,
            _horizontalPadding,
            20,
          ),
          child: const MeasureSkeletonBox(
            width: double.infinity,
            height: 48,
            borderRadius: 8,
          ),
        ),
      ],
    );
  }
}
