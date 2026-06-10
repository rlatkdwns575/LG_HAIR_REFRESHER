import 'package:flutter/material.dart';

import '../../data/measure_assets.dart';

/// 결과 분석 중 화면 일러스트.
class MeasureAnalyzingIllustration extends StatelessWidget {
  const MeasureAnalyzingIllustration({super.key});

  static const double height = 280;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.asset(
        MeasureAssets.analyzingIllustration,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
