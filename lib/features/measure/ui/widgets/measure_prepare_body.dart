import 'package:flutter/material.dart';

import '../../data/model/measure_prepare_step.dart';
import '../../data/model/measure_prepare_step_copy.dart';
import 'measure_prepare_image_area.dart';
import 'measure_prepare_instruction.dart';

/// Figma 40000052:24547 — 진단 준비 본문(이미지·안내 문구) 레이아웃.
class MeasurePrepareBody extends StatelessWidget {
  const MeasurePrepareBody({required this.step, super.key});

  final MeasurePrepareStep step;

  static const double horizontalPadding = 15;

  /// 스텝 인디케이터 ↔ 이미지.
  static const double indicatorToImageGap = 32;

  /// 이미지 ↔ 안내 문구.
  static const double imageToTextGap = 24;

  @override
  Widget build(BuildContext context) {
    final copy = MeasurePrepareStepCopy.forStep(step);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          const SizedBox(height: indicatorToImageGap),
          MeasurePrepareImageArea(step: step),
          const SizedBox(height: imageToTextGap),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: MeasurePrepareInstruction(
              key: ValueKey(step),
              title: copy.title,
              subtitle: copy.subtitle,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
