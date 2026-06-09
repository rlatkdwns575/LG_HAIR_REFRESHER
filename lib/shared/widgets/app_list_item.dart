import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_checkbox.dart';
import 'app_radio.dart';
import 'app_toggle.dart';

enum AppListItemVariant {
  chevron,
  chevronWithRightLabel,
  chevronWithoutRightLabel,
  noChevron,
  icon,
  check,
  checkbox,
  toggle,
  radio,
}

class AppListItem extends StatelessWidget {
  const AppListItem({
    required this.title,
    this.variant = AppListItemVariant.chevron,
    this.caption,
    this.rightLabel,
    this.leadingIcon,
    this.checked = false,
    this.selected = false,
    this.toggleValue = false,
    this.radioValue,
    this.radioGroupValue,
    this.onRadioChanged,
    this.onTap,
    this.onChanged,
    this.showChevron = true,
    this.showInfoIcon = false,
    this.onInfoTap,
    super.key,
  });

  final String title;
  final AppListItemVariant variant;
  final String? caption;
  final String? rightLabel;
  final IconData? leadingIcon;
  final bool checked;
  final bool selected;
  final bool toggleValue;
  final Object? radioValue;
  final Object? radioGroupValue;
  final ValueChanged<Object?>? onRadioChanged;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onChanged;
  final bool showChevron;
  final bool showInfoIcon;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ..._leadingWidgets(),
            Expanded(child: _buildTexts()),
            ..._trailingWidgets(),
          ],
        ),
      ),
    );
  }

  List<Widget> _leadingWidgets() {
    return switch (variant) {
      AppListItemVariant.icon => [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 24, color: AppComponentColors.listTitle),
          const SizedBox(width: 10),
        ],
      ],
      AppListItemVariant.check => [
        Icon(
          selected ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 24,
          color: selected
              ? AppComponentColors.radioOnFill
              : AppComponentColors.radioOffFill,
        ),
        const SizedBox(width: 8),
      ],
      AppListItemVariant.checkbox => [
        AppCheckbox(
          value: checked,
          onChanged: onChanged,
          size: AppCheckboxSize.large,
        ),
        const SizedBox(width: 8),
      ],
      _ => const [],
    };
  }

  Widget _buildTexts() {
    if (variant == AppListItemVariant.noChevron) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: AppTextStyles.bodyM1.copyWith(
                  color: AppComponentColors.listTitle,
                ),
              ),
              if (showInfoIcon) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onInfoTap,
                  child: const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppComponentColors.listInfoIcon,
                  ),
                ),
              ],
            ],
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: AppTextStyles.labelM.copyWith(
                color: AppComponentColors.listCaption,
              ),
            ),
          ],
        ],
      );
    }

    if (caption != null && variant == AppListItemVariant.chevron) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyM1.copyWith(
              color: AppComponentColors.listTitle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            caption!,
            style: AppTextStyles.labelM.copyWith(
              color: AppComponentColors.listCaption,
            ),
          ),
        ],
      );
    }

    if (variant == AppListItemVariant.checkbox && rightLabel != null) {
      return Row(
        children: [
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.bodyM1.copyWith(
                color: AppComponentColors.listTitle,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            rightLabel!,
            style: AppTextStyles.bodyM1.copyWith(
              color: AppComponentColors.listSubText,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: AppTextStyles.bodyM1.copyWith(color: AppComponentColors.listTitle),
    );
  }

  List<Widget> _trailingWidgets() {
    return switch (variant) {
      AppListItemVariant.chevronWithRightLabel => [
        if (rightLabel != null)
          Text(
            rightLabel!,
            style: AppTextStyles.bodyM1.copyWith(
              color: AppComponentColors.listRightLabel,
            ),
          ),
        if (showChevron) ...[
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            size: 16,
            color: AppComponentColors.listChevron,
          ),
        ],
      ],
      AppListItemVariant.chevron ||
      AppListItemVariant.chevronWithoutRightLabel ||
      AppListItemVariant.icon ||
      AppListItemVariant.check =>
        showChevron
            ? [
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppComponentColors.listChevron,
                ),
              ]
            : const [],
      AppListItemVariant.toggle => [
        AppToggle(value: toggleValue, onChanged: onChanged),
      ],
      AppListItemVariant.radio => [
        if (radioValue != null)
          AppRadio<Object>(
            value: radioValue!,
            groupValue: radioGroupValue,
            onChanged: onRadioChanged,
          ),
      ],
      AppListItemVariant.checkbox => const [],
      AppListItemVariant.noChevron => const [],
    };
  }
}
