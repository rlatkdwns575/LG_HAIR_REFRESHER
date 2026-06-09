import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class MeasurePrepareImageArea extends StatelessWidget {
  const MeasurePrepareImageArea({super.key});

  static const double height = 360;
  static const double imageRadius = 10;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(imageRadius),
      child: Container(
        width: double.infinity,
        height: height,
        color: AppColors.gray200,
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.gray400),
      ),
    );
  }
}
