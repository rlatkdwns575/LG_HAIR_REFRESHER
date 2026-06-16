import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_list_item.dart';

class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: AppTextStyles.labelM.copyWith(color: AppColors.gray600),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.gray0,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: AppColors.gray100);
  }
}

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    required this.title,
    this.caption,
    this.rightLabel,
    this.leadingIcon,
    this.variant = AppListItemVariant.chevron,
    this.toggleValue,
    this.onChanged,
    this.onTap,
    super.key,
  });

  final String title;
  final String? caption;
  final String? rightLabel;
  final IconData? leadingIcon;
  final AppListItemVariant variant;
  final bool? toggleValue;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: AppListItem(
        title: title,
        caption: caption,
        rightLabel: rightLabel,
        leadingIcon: leadingIcon,
        variant: variant,
        toggleValue: toggleValue ?? false,
        onChanged: onChanged,
        onTap: onTap,
        showChevron: variant != AppListItemVariant.toggle,
      ),
    );
  }
}
