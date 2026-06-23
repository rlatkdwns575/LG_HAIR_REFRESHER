/// 로컬 알림 예약 전 Android/iOS 권한 상태.
class NotificationScheduleReadiness {
  const NotificationScheduleReadiness({
    required this.notificationsEnabled,
    required this.exactAlarmsEnabled,
  });

  final bool notificationsEnabled;

  /// Android 12 미만이거나 미지원이면 true로 간주합니다.
  final bool exactAlarmsEnabled;

  bool get canSchedule => notificationsEnabled;

  bool get needsExactAlarmSettings =>
      notificationsEnabled && !exactAlarmsEnabled;
}
