import 'package:flutter/material.dart';

import '../../../../shared/widgets/feature_sub_page_scaffold.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return const FeatureSubPageScaffold(
      title: '설정 / 연동',
      description: '디바이스, 캘린더, 외부 환경 데이터, 알림을 관리합니다.',
      items: ['디바이스 연동', 'Google Calendar 연동', '외부 환경 데이터 연동', '알림 및 소모품 관리'],
    );
  }
}
