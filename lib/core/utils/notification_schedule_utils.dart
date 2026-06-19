import 'package:timezone/timezone.dart' as tz;

/// 로컬 알림 예약 시각 계산 유틸.
tz.TZDateTime nextZonedNotificationTime({
  required tz.Location location,
  required int weekday,
  required int hour,
  required int minute,
  tz.TZDateTime? now,
}) {
  final current = now ?? tz.TZDateTime.now(location);
  var scheduled = tz.TZDateTime(
    location,
    current.year,
    current.month,
    current.day,
    hour,
    minute,
  );

  while (scheduled.weekday != weekday || !scheduled.isAfter(current)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  return scheduled;
}
