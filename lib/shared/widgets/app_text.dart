import 'package:flutter/material.dart';

import '../../core/extensions/string_extension.dart';

export '../../core/extensions/string_extension.dart';

/// 본문 텍스트 위젯 — [StringExtension.softWrapWords]로 줄바꿈을 보정합니다.
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.softWrap,
    this.enableKoreanLineBreak = true,
    this.breakLinesBySentence = false,
    super.key,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool? softWrap;

  /// false이면 [data]를 그대로 표시합니다.
  final bool enableKoreanLineBreak;

    /// true이면 문장 종결·쉼표(`,`)마다 줄바꿈 후 구간 내부에 [softWrapWords]를 적용합니다.
  final bool breakLinesBySentence;

  @override
  Widget build(BuildContext context) {
    final displayText = breakLinesBySentence
        ? data.softWrapDescription()
        : enableKoreanLineBreak
        ? data.softWrapWords()
        : data;

    return Text(
      displayText,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
