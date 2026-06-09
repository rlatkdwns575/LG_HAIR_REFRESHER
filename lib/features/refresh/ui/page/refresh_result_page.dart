import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class RefreshResultPage extends StatefulWidget {
  const RefreshResultPage({super.key});

  @override
  State<RefreshResultPage> createState() => _RefreshResultPageState();
}

class _RefreshResultPageState extends State<RefreshResultPage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '리프레시 결과',
      description: '리프레시 완료 후 결과를 확인합니다.',
      items: ['헤어 먼지 변화', '헤어 냄새 변화', '종합 오염도 변화', '케어 완료'],
    );
  }
}
