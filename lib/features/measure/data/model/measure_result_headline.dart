import 'package:flutter/material.dart';

/// 진단 결과 상단 상태 메시지.
///
/// [plain] 은 안정형, [highlighted] 는 강조 구간이 있는 경고형 메시지입니다.
/// 두 타입 모두 동일한 [baseStyle] 로 렌더링합니다.
class MeasureResultHeadline {
  const MeasureResultHeadline.plain(this.text)
    : before = null,
      highlight = null,
      after = null,
      highlightColor = null;

  const MeasureResultHeadline.highlighted({
    required this.before,
    required this.highlight,
    required this.after,
    required this.highlightColor,
  }) : text = null;

  final String? text;
  final String? before;
  final String? highlight;
  final String? after;
  final Color? highlightColor;

  bool get isHighlighted => highlight != null;
}
