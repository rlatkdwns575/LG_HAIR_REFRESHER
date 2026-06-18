import 'package:flutter/material.dart';

import 'home_navigation_card.dart';

/// 홈 하단 네비 — 리프레시/진단/기록 모두 56px + chevron 행 탭.
class HomeNavigationMenu extends StatelessWidget {
  const HomeNavigationMenu({
    required this.onRefreshPressed,
    required this.onDiagnosisPressed,
    required this.onHistoryPressed,
    super.key,
  });

  static const cardGap = 6.0;

  final VoidCallback? onRefreshPressed;
  final VoidCallback? onDiagnosisPressed;
  final VoidCallback? onHistoryPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeActionCard(
          child: HomeTappableNavigationRow(
            title: '리프레시하기',
            onTap: onRefreshPressed,
          ),
        ),
        const SizedBox(height: cardGap),
        HomeActionCard(
          child: HomeTappableNavigationRow(
            title: '헤어 상태 진단하기',
            onTap: onDiagnosisPressed,
          ),
        ),
        const SizedBox(height: cardGap),
        HomeActionCard(
          child: HomeTappableNavigationRow(
            title: '리프레시 기록',
            onTap: onHistoryPressed,
          ),
        ),
      ],
    );
  }
}
