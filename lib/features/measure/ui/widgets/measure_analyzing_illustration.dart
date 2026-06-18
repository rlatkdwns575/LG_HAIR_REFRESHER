import 'package:flutter/material.dart';

import '../../data/measure_assets.dart';

/// 결과 분석 중 화면 일러스트.
class MeasureAnalyzingIllustration extends StatelessWidget {
  const MeasureAnalyzingIllustration({super.key});

  static const double size = 230;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          MeasureAssets.analyzingIllustration,
          width: size,
          height: size,
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
