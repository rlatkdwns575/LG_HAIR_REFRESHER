import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

class AppChipTabBar extends StatelessWidget {
  const AppChipTabBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected
                    ? AppComponentColors.chipSelectedBackground
                    : AppComponentColors.chipNormalBackground,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              alignment: Alignment.center,
              child: Text(
                tabs[index],
                style: AppTextStyles.labelM.copyWith(
                  color: selected
                      ? AppComponentColors.chipSelectedText
                      : AppComponentColors.chipNormalText,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
