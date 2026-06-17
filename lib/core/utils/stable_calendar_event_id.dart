import 'dart:convert';

/// 기기 일정 + 사용자 기준으로 안정적인 UUID 형식 event_id를 생성합니다.
String stableCalendarEventId({
  required String userId,
  required String deviceEventId,
  required DateTime startsAt,
}) {
  final seed =
      '$userId|$deviceEventId|${startsAt.toUtc().millisecondsSinceEpoch}';
  final bytes = utf8.encode(seed);

  var h0 = 0x811c9dc5;
  for (final byte in bytes) {
    h0 ^= byte;
    h0 = (h0 * 0x01000193) & 0xFFFFFFFF;
  }

  var h1 = h0;
  for (final byte in bytes.reversed) {
    h1 ^= byte;
    h1 = (h1 * 0x01000193) & 0xFFFFFFFF;
  }

  final part1 = h0.toRadixString(16).padLeft(8, '0');
  final part2 = (h1 & 0xFFFF).toRadixString(16).padLeft(4, '0');
  final part3 = (((h1 >> 16) & 0x0FFF) | 0x4000)
      .toRadixString(16)
      .padLeft(4, '0');
  final part4 = (((h0 >> 16) & 0x3FFF) | 0x8000)
      .toRadixString(16)
      .padLeft(4, '0');
  final part5 = ((h0 ^ h1) & 0xFFFFFFFF).toRadixString(16).padLeft(12, '0');

  return '$part1-$part2-$part3-$part4-$part5';
}
