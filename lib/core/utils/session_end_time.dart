/// `REFRESH_SESSIONS` 종료 시각 계산·비교.
class SessionEndTime {
  const SessionEndTime._();

  /// `ended_at` 우선, 없으면 `started_at + duration_time`.
  static DateTime? resolveEndTime({
    Object? endedAtRaw,
    Object? startedAtRaw,
    Object? durationTimeRaw,
  }) {
    final endedAt = _parseDateTime(endedAtRaw);
    if (endedAt != null) {
      return endedAt;
    }

    final startedAt = _parseDateTime(startedAtRaw);
    if (startedAt == null) {
      return null;
    }

    final durationSeconds = _readDurationSeconds(durationTimeRaw);
    if (durationSeconds == null || durationSeconds <= 0) {
      return startedAt;
    }

    return startedAt.add(Duration(seconds: durationSeconds));
  }

  /// 세션 종료 시각이 측정 시각 이후(이상)인지 확인합니다.
  static bool isEndTimeOnOrAfterMeasure({
    required DateTime measureCreatedAt,
    Object? endedAtRaw,
    Object? startedAtRaw,
    Object? durationTimeRaw,
  }) {
    final endTime = resolveEndTime(
      endedAtRaw: endedAtRaw,
      startedAtRaw: startedAtRaw,
      durationTimeRaw: durationTimeRaw,
    );
    if (endTime == null) {
      return false;
    }

    return !endTime.toUtc().isBefore(measureCreatedAt.toUtc());
  }

  static DateTime? _parseDateTime(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static int? _readDurationSeconds(Object? raw) {
    if (raw is num) {
      return raw.round();
    }
    return null;
  }
}
