import 'package:flutter/material.dart';

import 'measure_prepare_body.dart';
import 'measure_prepare_image_area.dart';
import 'measure_prepare_instruction.dart';
import 'measure_skeleton_box.dart';
import 'measure_step_indicator.dart';

class MeasurePrepareSkeleton extends StatelessWidget {
  const MeasurePrepareSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MeasureStepIndicator(
          currentStep: MeasureIntroStepIndicator.prepareStepOffset,
          totalSteps: MeasureIntroStepIndicator.totalSteps,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MeasurePrepareBody.horizontalPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: MeasurePrepareBody.indicatorToImageGap),
                const SizedBox(
                  width: double.infinity,
                  child: MeasureSkeletonBox(
                    width: double.infinity,
                    height: MeasurePrepareImageArea.height,
                    borderRadius: MeasurePrepareImageArea.imageRadius,
                  ),
                ),
                const SizedBox(height: MeasurePrepareBody.imageToTextGap),
                const MeasurePrepareInstruction(title: '', isLoading: true),
                const Spacer(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            MeasurePrepareBody.horizontalPadding,
            10,
            MeasurePrepareBody.horizontalPadding,
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
