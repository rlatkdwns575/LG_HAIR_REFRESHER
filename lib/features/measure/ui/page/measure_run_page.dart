import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class MeasureRunPage extends StatefulWidget {
  const MeasureRunPage({super.key});

  @override
  State<MeasureRunPage> createState() => _MeasureRunPageState();
}

class _MeasureRunPageState extends State<MeasureRunPage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '진단 실행',
      description: '측정 진행 중 상태를 표시합니다.',
      items: ['길이 측정 중', '머리 손상 측정 중', '먼지 / 냄새 측정 중', '측정 진행 상황 표시'],
    );
  }
}
