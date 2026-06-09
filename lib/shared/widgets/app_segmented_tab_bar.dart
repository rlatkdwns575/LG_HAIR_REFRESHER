import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';

class AppSegmentedTabBar extends StatelessWidget {
  const AppSegmentedTabBar({
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
    return Container(
      height: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppComponentColors.segmentedBackground,
        borderRadius: BorderRadius.circular(AppRadius.segmented),
        border: Border.all(color: AppComponentColors.segmentedBorder),
      ),
      child: Row(
        children: [
          for (var index = 0; index < tabs.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? AppComponentColors.segmentedSelectedBackground
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Text(
                    tabs[index],
                    style: AppTextStyles.labelM.copyWith(
                      color: selectedIndex == index
                          ? AppComponentColors.segmentedSelectedText
                          : AppComponentColors.segmentedNormalText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
