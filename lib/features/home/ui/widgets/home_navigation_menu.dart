import 'package:flutter/material.dart';

import 'home_navigation_card.dart';

/// 홈 하단 네비 — 리프레시/진단/내역 모두 62px + chevron 행 탭.
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
            title: '헤어 리프레시',
            onTap: onRefreshPressed,
          ),
        ),
        const SizedBox(height: cardGap),
        HomeActionCard(
          child: HomeTappableNavigationRow(
            title: '헤어 상태 진단',
            onTap: onDiagnosisPressed,
          ),
        ),
        const SizedBox(height: cardGap),
        HomeActionCard(
          child: HomeTappableNavigationRow(
            title: '리프레시 내역',
            onTap: onHistoryPressed,
          ),
        ),
      ],
    );
  }
}
