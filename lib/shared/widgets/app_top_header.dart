import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';

class AppTopHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppTopHeader({
    required this.title,
    this.leading,
    this.actions = const [],
    super.key,
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppComponentColors.headerBackground,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: NavigationToolbar(
            leading: leading,
            middle: Text(
              title,
              style: AppTextStyles.headlineM.copyWith(
                color: AppComponentColors.headerTitle,
              ),
            ),
            centerMiddle: true,
            trailing: actions.isEmpty
                ? null
                : Row(mainAxisSize: MainAxisSize.min, children: actions),
          ),
        ),
      ),
    );
  }
}
