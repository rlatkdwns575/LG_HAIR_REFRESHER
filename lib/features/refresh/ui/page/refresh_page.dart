import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class RefreshPage extends StatefulWidget {
  const RefreshPage({super.key});

  @override
  State<RefreshPage> createState() => _RefreshPageState();
}

class _RefreshPageState extends State<RefreshPage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '리프레시',
      description: '추천 모드 또는 전체 모드에서 케어를 실행합니다.',
      items: ['퀵 리프레시', '미팅 케어', '취침 케어', '외출 케어'],
    );
  }
}
