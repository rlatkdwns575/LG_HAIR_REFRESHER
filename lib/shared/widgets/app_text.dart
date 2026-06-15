import 'package:flutter/material.dart';

/// 본문 텍스트 위젯 — 기본 [Text] 동작을 따릅니다.
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.enableKoreanLineBreak = true,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  /// 더 이상 사용하지 않음. 호출부 호환을 위해 남겨둡니다.
  final bool enableKoreanLineBreak;

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
