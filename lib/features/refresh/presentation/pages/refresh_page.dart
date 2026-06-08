import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_page.dart';

class RefreshPage extends StatelessWidget {
  const RefreshPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: '리프레시',
      description: '추천 모드 또는 전체 모드에서 케어를 실행합니다.',
      items: ['퀵 리프레시', '만남 전 케어', '취침 전 케어', '외출 후 케어'],
    );
  }
}
