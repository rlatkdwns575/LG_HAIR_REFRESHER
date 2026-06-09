import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_box_button.dart';

class MeasurePrepareBottomBar extends StatelessWidget {
  const MeasurePrepareBottomBar({
    required this.label,
    required this.enabled,
    this.onPressed,
    super.key,
  });

  final String label;
  final bool enabled;
  final VoidCallback? onPressed;

  // 상단 패딩(10) + 순수 버튼 높이(48) + 하단 패딩(68) = 126
  static const double _barHeight = 126;
  static const double _horizontalPadding = 15;
  static const double _topPadding = 10;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SizedBox(
        height: _barHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            _horizontalPadding,
            _topPadding,
            _horizontalPadding,
            68, // 하단 패딩 68
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            // AppBoxButton 대신 Flutter 기본 위젯인 SizedBox에 key를 부여함
            child: SizedBox(
              key: ValueKey(enabled), // enabled 상태 변경을 감지하기 위한 고유 키
              width: double.infinity,
              child: AppBoxButton(
                label: label,
                onPressed: enabled ? onPressed : null,
                variant: enabled
                    ? AppBoxButtonVariant.active
                    : AppBoxButtonVariant.disabled,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
