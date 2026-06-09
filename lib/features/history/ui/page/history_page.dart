import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_placeholder_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: '사용기록',
      description: '측정 결과와 리프레시 결과를 날짜별로 확인합니다.',
      items: ['측정 결과 기록', '리프레시 결과 기록', '자주 사용한 모드', '주간 / 월간 사용 추이'],
    );
  }
}
