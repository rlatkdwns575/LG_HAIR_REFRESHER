import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'LG Hair Refresher',
      description: '최근 상태와 추천 행동을 빠르게 확인하는 홈 대시보드입니다.',
      items: ['최근 리프레시 결과', '최근 측정 결과', '외부 환경 기반 추천', '자주 사용하는 모드 기반 추천'],
    );
  }
}
