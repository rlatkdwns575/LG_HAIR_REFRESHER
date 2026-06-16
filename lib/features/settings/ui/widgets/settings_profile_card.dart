import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/settings_user_summary.dart';

class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({required this.user, super.key});

  final SettingsUserSummary user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(AppRadius.field),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.primary500,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: AppTextStyles.titleS.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.profileLine,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
