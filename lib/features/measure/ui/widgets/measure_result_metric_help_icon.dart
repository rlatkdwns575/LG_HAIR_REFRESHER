import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/layout/app_layout.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';

/// 진단 상세 지표 옆 (?) 도움말 — 호버·탭 시 설명 표시.
class MeasureResultMetricHelpIcon extends StatelessWidget {
  const MeasureResultMetricHelpIcon({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: AppTextStyles.bodyXs.copyWith(
        color: AppColors.gray800,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.gray200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      waitDuration: const Duration(milliseconds: 150),
      showDuration: const Duration(seconds: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHelpDialog(context),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.help_outline, size: 14, color: AppColors.gray500),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      builder: (dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: AppLayout.popupConstraintsFor(dialogContext),
            child: GestureDetector(
              onTap: () => Navigator.of(dialogContext).pop(),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gray0,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.gray200),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AppText(
                    message,
                    style: AppTextStyles.bodyXs.copyWith(
                      color: AppColors.gray800,
                      fontWeight: FontWeight.w500,
                      height: 16 / 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
