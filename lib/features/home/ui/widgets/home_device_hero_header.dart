import 'package:flutter/material.dart';

import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_text.dart';

/// 홈 디바이스 이미지 위에 겹치는 타이틀·설정 헤더.
class HomeDeviceHeroHeader extends StatelessWidget {
  const HomeDeviceHeroHeader({
    required this.title,
    this.onSettingsPressed,
    super.key,
  });

  final String title;
  final VoidCallback? onSettingsPressed;

  static const height = 52.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppCommonTopHeader.pageHorizontalInset,
          ),
          child: Row(
            children: [
              Expanded(
                child: AppText(
                  title,
                  style: AppTextStyles.titleM.copyWith(
                    color: AppComponentColors.headerTitle,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSettingsPressed != null)
                IconButton(
                  onPressed: onSettingsPressed,
                  icon: const Icon(
                    Icons.settings_outlined,
                    size: 24,
                    color: AppComponentColors.headerTitle,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
