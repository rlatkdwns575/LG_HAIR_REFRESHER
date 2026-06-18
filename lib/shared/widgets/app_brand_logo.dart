import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/constants/image_assets.dart';

/// LG PuriHair 브랜드 워드마크 (Figma SVG).
class AppBrandLogo extends StatelessWidget {
  const AppBrandLogo({super.key, this.width = designWidth});

  static const designWidth = 198.0;
  static const designHeight = 29.0;

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      ImageAssets.homeBrandLogo,
      width: width,
      fit: BoxFit.contain,
      semanticsLabel: 'LG PuriHair',
    );
  }
}
