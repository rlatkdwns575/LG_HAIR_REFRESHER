import 'package:flutter/material.dart';

/// 진단 결과 화면의 항목별 관리 상태 (냄새/먼지 등).
class MeasureResultStatusItem {
  const MeasureResultStatusItem({
    required this.categoryLabel,
    required this.badgeLabel,
    required this.dotColor,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
  });

  final String categoryLabel;
  final String badgeLabel;
  final Color dotColor;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
}
