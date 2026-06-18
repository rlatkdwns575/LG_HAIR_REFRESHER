import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/routine.dart';

/// 리프레시 모드를 고르는 모달 바텀시트.
Future<RoutineModeOption?> showRoutineModePicker({
  required BuildContext context,
  required List<RoutineModeOption> options,
  String? selectedId,
}) {
  return showModalBottomSheet<RoutineModeOption>(
    context: context,
    backgroundColor: AppColors.gray0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.dialog),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                '리프레시 모드 선택',
                style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.id == selectedId;
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.name,
                              style: AppTextStyles.bodyM1.copyWith(
                                color: isSelected
                                    ? AppColors.primary500
                                    : AppColors.gray900,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: AppColors.primary500,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
    },
  );
}
