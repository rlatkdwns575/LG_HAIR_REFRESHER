import 'package:flutter/material.dart';

class AppSpacing {
  const AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  const AppSpacingExtension({
    required this.pagePadding,
    required this.sectionGap,
  });

  static const regular = AppSpacingExtension(
    pagePadding: EdgeInsets.all(AppSpacing.md),
    sectionGap: AppSpacing.lg,
  );

  final EdgeInsets pagePadding;
  final double sectionGap;

  @override
  AppSpacingExtension copyWith({EdgeInsets? pagePadding, double? sectionGap}) {
    return AppSpacingExtension(
      pagePadding: pagePadding ?? this.pagePadding,
      sectionGap: sectionGap ?? this.sectionGap,
    );
  }

  @override
  AppSpacingExtension lerp(
    ThemeExtension<AppSpacingExtension>? other,
    double t,
  ) {
    if (other is! AppSpacingExtension) {
      return this;
    }

    return AppSpacingExtension(
      pagePadding: EdgeInsets.lerp(pagePadding, other.pagePadding, t)!,
      sectionGap: lerpDouble(sectionGap, other.sectionGap, t),
    );
  }
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
