import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// `오전/오후 h:mm` 형식.
String formatKoreanTime(DateTime time) {
  final isAm = time.hour < 12;
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '${isAm ? '오전' : '오후'} $hour12:$minute';
}

/// `M월 d일 요일` 형식.
String formatKoreanDateWithWeekday(DateTime date) {
  final weekday = _weekdayLabels[date.weekday - 1];
  return '${date.month}월 ${date.day}일 $weekday요일';
}

/// `yyyy년 M월 d일 기준` 형식.
String formatKoreanAsOf(DateTime date) {
  return '${date.year}년 ${date.month}월 ${date.day}일 기준';
}

/// 섹션 사이를 구분하는 두꺼운 회색 구분선.
class HistorySectionDivider extends StatelessWidget {
  const HistorySectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: AppColors.gray100);
  }
}

/// 흰색 라운드 카드 (옅은 테두리).
class HistoryWhiteCard extends StatelessWidget {
  const HistoryWhiteCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = AppColors.gray0,
    this.borderColor = AppColors.gray100,
    this.borderRadius = 16,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      child: child,
    );
  }
}

/// `라벨 ... 값` 한 줄 (좌측 회색 라벨, 우측 강조 값).
class HistoryKeyValueRow extends StatelessWidget {
  const HistoryKeyValueRow({
    required this.label,
    required this.value,
    this.valueColor = AppColors.gray900,
    this.trailingDelta,
    super.key,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String? trailingDelta;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
          ),
        ),
        const SizedBox(width: 12),
        if (trailingDelta != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTextStyles.bodyM2.copyWith(color: valueColor),
              ),
              const SizedBox(width: 2),
              Text(
                trailingDelta!,
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ],
          )
        else
          Text(value, style: AppTextStyles.bodyM2.copyWith(color: valueColor)),
      ],
    );
  }
}
