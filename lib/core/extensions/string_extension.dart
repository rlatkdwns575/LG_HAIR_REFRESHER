extension StringExtension on String {
  String softWrapWords() {
    return replaceAllMapped(RegExp(r'(\S)(?=\S)'), (m) => '${m[1]}\u200D');
  }

  /// 문장 종결(`.`, `?`, `!`, `。`)과 `,` 뒤 줄바꿈 후, 각 구간에 [softWrapWords]를 적용합니다.
  String softWrapDescription() {
    if (isEmpty) {
      return this;
    }

    final normalized = replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');
    final segments = <String>[];
    final buffer = StringBuffer();

    for (var i = 0; i < normalized.length; i++) {
      buffer.write(normalized[i]);
      if ('.!?。,'.contains(normalized[i])) {
        final segment = buffer.toString().trim();
        if (segment.isNotEmpty) {
          segments.add(segment);
        }
        buffer.clear();
      }
    }

    final remainder = buffer.toString().trim();
    if (remainder.isNotEmpty) {
      segments.add(remainder);
    }

    if (segments.isEmpty) {
      return normalized.softWrapWords();
    }

    return segments.map((segment) => segment.softWrapWords()).join('\n');
  }
}
