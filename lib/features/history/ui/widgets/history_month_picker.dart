import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';

/// 연·월 선택 다이얼로그. 선택 시 해당 월 1일 [DateTime]을 반환합니다.
Future<DateTime?> showHistoryMonthPicker({
  required BuildContext context,
  required DateTime initialMonth,
  required DateTime maxMonth,
  DateTime? minMonth,
}) {
  final normalizedInitial = DateTime(initialMonth.year, initialMonth.month);
  final normalizedMax = DateTime(maxMonth.year, maxMonth.month);
  final min = minMonth ?? DateTime(1970, 1);
  final normalizedMin = DateTime(min.year, min.month);

  var selectedYear = normalizedInitial.year.clamp(
    normalizedMin.year,
    normalizedMax.year,
  );
  var selectedMonth = normalizedInitial.month;

  if (selectedYear == normalizedMax.year) {
    selectedMonth = selectedMonth.clamp(1, normalizedMax.month);
  }
  if (selectedYear == normalizedMin.year) {
    selectedMonth = selectedMonth.clamp(normalizedMin.month, 12);
  }

  final years = List.generate(
    normalizedMax.year - normalizedMin.year + 1,
    (index) => normalizedMin.year + index,
  );

  int maxMonthForYear(int year) {
    if (year == normalizedMax.year) {
      return normalizedMax.month;
    }
    if (year == normalizedMin.year) {
      return 12;
    }
    return 12;
  }

  int minMonthForYear(int year) {
    if (year == normalizedMin.year) {
      return normalizedMin.month;
    }
    return 1;
  }

  return showDialog<DateTime>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final monthStart = minMonthForYear(selectedYear);
          final monthEnd = maxMonthForYear(selectedYear);
          if (selectedMonth < monthStart) {
            selectedMonth = monthStart;
          }
          if (selectedMonth > monthEnd) {
            selectedMonth = monthEnd;
          }

          return Dialog(
            backgroundColor: AppComponentColors.dialogBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.dialog),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '년월 선택',
                    style: AppTextStyles.titleM.copyWith(
                      color: AppComponentColors.dialogText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerField(
                          label: '년도',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedYear,
                              isExpanded: true,
                              style: AppTextStyles.bodyM2.copyWith(
                                color: AppColors.gray900,
                              ),
                              items: [
                                for (final year in years)
                                  DropdownMenuItem(
                                    value: year,
                                    child: Text('$year년'),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  selectedYear = value;
                                  final start = minMonthForYear(selectedYear);
                                  final end = maxMonthForYear(selectedYear);
                                  selectedMonth = selectedMonth.clamp(
                                    start,
                                    end,
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerField(
                          label: '월',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedMonth,
                              isExpanded: true,
                              style: AppTextStyles.bodyM2.copyWith(
                                color: AppColors.gray900,
                              ),
                              items: [
                                for (
                                  var month = monthStart;
                                  month <= monthEnd;
                                  month++
                                )
                                  DropdownMenuItem(
                                    value: month,
                                    child: Text('$month월'),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => selectedMonth = value);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppBoxButton(
                          label: '취소',
                          variant: AppBoxButtonVariant.line,
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppBoxButton(
                          label: '확인',
                          variant: AppBoxButtonVariant.active,
                          onPressed: () => Navigator.of(
                            dialogContext,
                          ).pop(DateTime(selectedYear, selectedMonth)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _PickerField extends StatelessWidget {
  const _PickerField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelM.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.gray200),
          ),
          child: child,
        ),
      ],
    );
  }
}
