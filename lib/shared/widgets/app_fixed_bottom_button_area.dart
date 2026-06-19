import 'package:flutter/material.dart';

import '../../app/navigation/app_system_insets.dart';

/// Figma fixed bottom CTA padding — 좌우 15, 위 10, 아래 20 + system nav inset (min 48).
class AppBottomButtonLayout {
  const AppBottomButtonLayout._();

  static const horizontal = 15.0;
  static const top = 10.0;
  static const bottom = 20.0;

  static EdgeInsets padding(BuildContext context) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      bottom + AppSystemInsets.bottomOf(context),
    );
  }
}

/// 화면 하단 고정 CTA 영역. [AppBottomButtonLayout] padding을 적용합니다.
class AppFixedBottomButtonArea extends StatelessWidget {
  const AppFixedBottomButtonArea({
    required this.child,
    this.backgroundColor,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: Padding(
        padding: AppBottomButtonLayout.padding(context),
        child: child,
      ),
    );
  }
}
