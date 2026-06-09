import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class MeasureResultPage extends StatefulWidget {
  const MeasureResultPage({super.key});

  @override
  State<MeasureResultPage> createState() => _MeasureResultPageState();
}

class _MeasureResultPageState extends State<MeasureResultPage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '진단 결과',
      description: '측정 결과 확인 및 추천 연결 화면입니다.',
      items: ['헤어 손상도', '헤어 먼지', '헤어 냄새', '종합 오염도', '측정 결과 기반 추천'],
    );
  }
}
