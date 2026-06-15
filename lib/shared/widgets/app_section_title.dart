import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text.dart';

class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleL.copyWith(
            color: AppComponentColors.sectionTitle,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          AppText(
            subtitle!,
            style: AppTextStyles.bodyS.copyWith(
              color: AppComponentColors.sectionSubtitle,
            ),
          ),
        ],
      ],
    );
  }
}
