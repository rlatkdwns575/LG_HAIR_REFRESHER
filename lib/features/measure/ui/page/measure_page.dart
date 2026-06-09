import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class MeasurePage extends StatefulWidget {
  const MeasurePage({super.key});

  @override
  State<MeasurePage> createState() => _MeasurePageState();
}

class _MeasurePageState extends State<MeasurePage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '측정',
      description: '모발과 두피 상태를 측정하고 결과를 저장합니다.',
      items: ['현재 헤어 상태 측정', '측정 진행 상태 관리', '종합 오염도 분석', '냄새, 먼지, 손상도 분석'],
    );
  }
}
