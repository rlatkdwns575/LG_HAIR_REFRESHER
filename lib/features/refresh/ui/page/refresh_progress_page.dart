import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class RefreshProgressPage extends StatefulWidget {
  const RefreshProgressPage({super.key});

  @override
  State<RefreshProgressPage> createState() => _RefreshProgressPageState();
}

class _RefreshProgressPageState extends State<RefreshProgressPage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '리프레시 진행',
      description: '선택한 모드로 리프레시가 진행 중입니다.',
      items: ['준비 중', '먼지 제거 중', '탈취 중', '리프레시 진행 상황 표시'],
    );
  }
}
