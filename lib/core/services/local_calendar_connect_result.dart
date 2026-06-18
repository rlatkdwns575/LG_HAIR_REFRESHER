import '../../shared/models/local_calendar_status.dart';

/// 로컬 캘린더 연동 결과.
enum LocalCalendarConnectOutcome {
  skipped,
  cancelled,
  connected,
  permissionDenied,
  syncFailed,
}

class LocalCalendarConnectResult {
  const LocalCalendarConnectResult({
    required this.outcome,
    this.status,
    this.errorMessage,
  });

  final LocalCalendarConnectOutcome outcome;
  final LocalCalendarStatus? status;
  final String? errorMessage;

  bool get isConnected =>
      outcome == LocalCalendarConnectOutcome.connected &&
      (status?.isConnected ?? false);
}
