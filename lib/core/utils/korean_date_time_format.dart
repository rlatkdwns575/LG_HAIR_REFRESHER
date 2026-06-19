const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// `오전/오후 h:mm` 형식.
String formatKoreanTime(DateTime time) {
  final local = time.toLocal();
  final isAm = local.hour < 12;
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '${isAm ? '오전' : '오후'} $hour12:$minute';
}

/// `M월 d일 요일` 형식.
String formatKoreanDateWithWeekday(DateTime date) {
  final local = date.toLocal();
  final weekday = _weekdayLabels[local.weekday - 1];
  return '${local.month}월 ${local.day}일 $weekday요일';
}

/// `6월 10일 수요일 · 오후 7:38 완료` 형식.
String formatKoreanCompletionLabel(DateTime completedAt) {
  final local = completedAt.toLocal();
  return '${formatKoreanDateWithWeekday(local)} · ${formatKoreanTime(local)} 완료';
}
