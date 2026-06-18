import 'package:flutter/material.dart';

import '../../data/refresh_assets.dart';

/// 리프레시 결과 수집 중 화면 일러스트.
class RefreshResultCollectingIllustration extends StatelessWidget {
  const RefreshResultCollectingIllustration({super.key});

  static const double height = 200;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.asset(
        RefreshAssets.collectingIllustration,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
