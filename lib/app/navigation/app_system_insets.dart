import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Android system navigation bar 등 하단 system inset.
///
/// Material 3 navigation bar 권장 높이는 **48dp**입니다.
/// 실제 기기 [MediaQuery] inset이 더 크면 그 값을 쓰고, 더 작으면 48dp를 floor로
/// 적용합니다.
class AppSystemInsets {
  const AppSystemInsets._();

  static const navigationBarMinHeight = 48.0;

  static double bottomOf(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    return math.max(
      math.max(padding.bottom, viewPadding.bottom),
      navigationBarMinHeight,
    );
  }

  static EdgeInsets onlyBottom(BuildContext context, {double extra = 0}) {
    return EdgeInsets.only(bottom: extra + bottomOf(context));
  }

  static EdgeInsets pageHorizontal(
    BuildContext context, {
    double horizontal = 15,
    double top = 0,
    double extraBottom = AppSpacing.xl,
  }) {
    return EdgeInsets.fromLTRB(
      horizontal,
      top,
      horizontal,
      extraBottom + bottomOf(context),
    );
  }
}
