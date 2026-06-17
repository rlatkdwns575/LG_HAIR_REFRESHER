import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Figma 1224-23687 — 모발 유형 그리드 선택 칩.
class MeasureHairProfileRadioTile extends StatelessWidget {
  const MeasureHairProfileRadioTile({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const double tileHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary100 : AppColors.gray50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        side: BorderSide(
          color: selected ? AppColors.primary500 : AppColors.gray100,
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: tileHeight,
          child: Center(
            child: AppText(
              label,
              style: AppTextStyles.bodyM1.copyWith(
                color: selected ? AppColors.primary500 : AppColors.gray800,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
