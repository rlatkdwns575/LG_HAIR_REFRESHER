import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/utils/korean_date_time_format.dart';

void main() {
  group('formatKoreanCompletionLabel', () {
    test('formats date, weekday, time, and completion suffix', () {
      final completedAt = DateTime(2026, 6, 10, 19, 38);

      expect(
        formatKoreanCompletionLabel(completedAt),
        '6월 10일 수요일 · 오후 7:38 완료',
      );
    });

    test('formats morning time with zero-padded minutes', () {
      final completedAt = DateTime(2026, 6, 10, 9, 5);

      expect(
        formatKoreanCompletionLabel(completedAt),
        '6월 10일 수요일 · 오전 9:05 완료',
      );
    });
  });
}
