import 'package:flutter/material.dart';

import '../../data/measure_assets.dart';
import '../../data/model/measure_prepare_step.dart';

class MeasurePrepareImageArea extends StatelessWidget {
  const MeasurePrepareImageArea({required this.step, super.key});

  final MeasurePrepareStep step;

  /// Figma 40000052:24547 — 준비 화면 이미지 영역 높이.
  static const double height = 320;
  static const double imageRadius = 10;

  @override
  Widget build(BuildContext context) {
    final asset = MeasureAssets.imageForPrepareStep(step);

    return ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Image.asset(
            asset,
            key: ValueKey(asset),
            width: double.infinity,
            height: height,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    );
  }
}
