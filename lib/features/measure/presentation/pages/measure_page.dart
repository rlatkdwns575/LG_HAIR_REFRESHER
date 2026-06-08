import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_page.dart';

class MeasurePage extends StatelessWidget {
  const MeasurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: '측정',
      description: '모발과 두피 상태를 측정하고 결과를 저장합니다.',
      items: ['현재 헤어 상태 측정', '측정 진행 상태 관리', '종합 오염도, 냄새, 먼지, 손상도 분석'],
    );
  }
}
