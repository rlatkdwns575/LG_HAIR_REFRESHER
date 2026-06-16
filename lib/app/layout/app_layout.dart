import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_page_backgrounds.dart';

/// 앱 공통 레이아웃 상수.
class AppLayout {
  const AppLayout._();

  /// 본문 콘텐츠 최대 너비. 더 넓은 화면은 좌우 여백으로 처리합니다.
  static const maxContentWidth = 540.0;

  static const _popupHorizontalMargin = 16.0;

  /// 다이얼로그·바텀시트 등 팝업 최대 너비.
  static const popupConstraints = BoxConstraints(maxWidth: maxContentWidth);

  /// 화면 너비에 맞춘 팝업 최대 너비 (좌우 16dp 여유).
  static BoxConstraints popupConstraintsFor(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BoxConstraints(
      maxWidth: math.min(maxContentWidth, width - _popupHorizontalMargin * 2),
    );
  }
}

/// 540dp 제한 + 좌우 여백을 해당 화면 Scaffold 배경과 동일하게 맞춥니다.
///
/// - [path]: 라우트 경로 → [AppPageBackgrounds.forPath]
/// - [backgroundColor]: 홈 등 직접 지정
class AppMaxWidthPageShell extends StatelessWidget {
  const AppMaxWidthPageShell({
    required this.child,
    this.backgroundColor,
    this.path,
    super.key,
  });

  final Widget child;
  final Color? backgroundColor;
  final String? path;

  Color _resolveBackground(BuildContext context) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    if (path != null) {
      return AppPageBackgrounds.forPath(path!);
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    final background = _resolveBackground(context);

    return ColoredBox(
      color: background,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppLayout.maxContentWidth,
          ),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

/// 배경색 없이 540dp만 제한할 때.
class AppMaxWidthContainer extends StatelessWidget {
  const AppMaxWidthContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
        child: child,
      ),
    );
  }
}
