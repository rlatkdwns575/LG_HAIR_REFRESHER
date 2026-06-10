import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/model/measure_result_headline.dart' as model;

/// 진단 결과 상태 메시지 (안정형/경고형 공통 스타일).
class MeasureResultHeadline extends StatelessWidget {
  const MeasureResultHeadline({required this.headline, super.key});

  final model.MeasureResultHeadline headline;

  static final TextStyle _baseStyle = AppTextStyles.titleL.copyWith(
    color: AppColors.gray800,
  );

  @override
  Widget build(BuildContext context) {
    if (!headline.isHighlighted) {
      return Text(
        headline.text!,
        textAlign: TextAlign.center,
        style: _baseStyle,
      );
    }

    final before = headline.before!.trimRight();

    return Text.rich(
      TextSpan(
        style: _baseStyle,
        children: [
          TextSpan(text: '$before\n'),
          TextSpan(
            text: headline.highlight,
            style: TextStyle(color: headline.highlightColor),
          ),
          TextSpan(text: headline.after),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
