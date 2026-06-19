import 'package:flutter/material.dart';

import '../../data/measure_result_visual_mapper.dart';
import '../../data/model/measure_care_level.dart';

/// Figma 40000056:18420 — 진단 결과 간편보기 상태 그래픽 (160×160).
class MeasureResultVisual extends StatelessWidget {
  const MeasureResultVisual({
    required this.odorLevel,
    required this.dustLevel,
    super.key,
  });

  /// Figma `img area` — 160×160, 헤드라인 아래 24px.
  static const double size = 160;

  final MeasureCareLevel odorLevel;
  final MeasureCareLevel dustLevel;

  @override
  Widget build(BuildContext context) {
    final assetPath = MeasureResultVisualMapper.assetPath(
      odorLevel: odorLevel,
      dustLevel: dustLevel,
    );

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
