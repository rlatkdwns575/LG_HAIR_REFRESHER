import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'navigation/app_system_insets.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class LgHairRefresherApp extends StatelessWidget {
  const LgHairRefresherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LG PuriHair',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
      builder: (context, child) {
        if (child == null) {
          return const SizedBox.shrink();
        }

        final padding = MediaQuery.paddingOf(context);
        final viewPadding = MediaQuery.viewPaddingOf(context);
        final bottomInset = math.max(
          math.max(padding.bottom, viewPadding.bottom),
          AppSystemInsets.navigationBarMinHeight,
        );

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: padding.copyWith(bottom: bottomInset),
            viewPadding: viewPadding.copyWith(bottom: bottomInset),
          ),
          child: child,
        );
      },
    );
  }
}
