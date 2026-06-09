import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_box_button.dart';

class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    required this.title,
    required this.message,
    this.primaryLabel = '버튼명',
    this.secondaryLabel,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.middleContent,
    super.key,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final Widget? middleContent;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String primaryLabel = '확인',
    String? secondaryLabel = '취소',
    Widget? middleContent,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        message: message,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        middleContent: middleContent,
        onPrimaryPressed: () => Navigator.of(context).pop(true),
        onSecondaryPressed: secondaryLabel == null
            ? null
            : () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppComponentColors.dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.dialog),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleM.copyWith(
                color: AppComponentColors.dialogText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM1.copyWith(
                color: AppComponentColors.dialogText,
              ),
            ),
            if (middleContent != null) ...[
              const SizedBox(height: 16),
              middleContent!,
            ],
            const SizedBox(height: 24),
            if (secondaryLabel == null)
              AppBoxButton(
                label: primaryLabel,
                onPressed: onPrimaryPressed,
                size: AppBoxButtonSize.medium,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppBoxButton(
                      label: secondaryLabel!,
                      onPressed: onSecondaryPressed,
                      size: AppBoxButtonSize.small,
                      variant: AppBoxButtonVariant.line,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppBoxButton(
                      label: primaryLabel,
                      onPressed: onPrimaryPressed,
                      size: AppBoxButtonSize.small,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
