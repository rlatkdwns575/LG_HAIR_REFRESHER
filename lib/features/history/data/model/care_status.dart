import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// 냄새/먼지 케어 상태 단계.
///
/// 배지 색은 Figma 리프레시 기록 리포트 기준이며, 추후 API 의 상태 코드와
/// 매핑하기 쉽도록 [fromCode] 를 제공합니다.
enum CareStatus {
  focusedRecommend('집중권장', AppColors.orange100, AppColors.orange700),
  focusedRequired('집중필요', AppColors.red200, AppColors.red700),
  recommend('권장', AppColors.green200, AppColors.green700),
  good('좋음', AppColors.blue200, AppColors.blue700),
  normal('보통', AppColors.safe100, AppColors.safe500),
  notNeeded('불필요', AppColors.blue100, AppColors.blue800);

  const CareStatus(this.label, this.backgroundColor, this.textColor);

  final String label;
  final Color backgroundColor;
  final Color textColor;

  /// API/Supabase 의 문자열 코드 → enum 매핑. 미매칭 시 [normal] 반환.
  static CareStatus fromCode(String? code) {
    return CareStatus.values.firstWhere(
      (status) => status.name == code || status.label == code,
      orElse: () => CareStatus.normal,
    );
  }
}
