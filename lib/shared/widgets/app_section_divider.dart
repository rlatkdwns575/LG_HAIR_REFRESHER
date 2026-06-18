import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// 상세 화면 본문 좌우 패딩. [AppSectionDivider]는 이 패딩 밖에 둡니다.
class DetailPageHorizontalPadding extends StatelessWidget {
  const DetailPageHorizontalPadding({required this.child, super.key});

  static const double value = 15;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: value),
      child: child,
    );
  }
}

/// Figma `divider` — 섹션 구분용 8px 회색 바 (좌우 끝까지).
class AppSectionDivider extends StatelessWidget {
  const AppSectionDivider({this.verticalSpacing = 32, super.key});

  static const double barHeight = 8;

  final double verticalSpacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalSpacing),
      child: Container(height: barHeight, color: AppColors.gray50),
    );
  }
}
