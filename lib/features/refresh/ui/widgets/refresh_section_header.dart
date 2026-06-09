import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class RefreshSectionHeader extends StatelessWidget {
  const RefreshSectionHeader({
    required this.title,
    this.subtitle,
    this.trailingLabel,
    this.onTrailingTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, left: 15, right: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleM.copyWith(
                    color: AppColors.gray800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailingLabel != null)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailingLabel!,
                    style: AppTextStyles.labelM.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
