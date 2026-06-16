import '../../shared/models/local_calendar_status.dart';
import 'local_calendar_connection_store.dart';

/// 기기 로컬 캘린더 연동·상태 확인.
class LocalCalendarService {
  const LocalCalendarService();

  LocalCalendarConnectionStore get _store =>
      LocalCalendarConnectionStore.instance;

  LocalCalendarStatus get currentStatus => _buildStatus();

  Future<LocalCalendarStatus> fetchStatus() async {
    return _buildStatus();
  }

  Future<LocalCalendarStatus> requestAccess() async {
    _store.grantPermission();
    return refreshConnection();
  }

  /// 기기 캘린더에서 일정을 읽어 연동 상태를 검증합니다.
  ///
  /// 실제 OS 캘린더 API 연동 전까지는 허용된 권한 기준으로
  /// 샘플 일정을 반환해 UI 흐름을 확인할 수 있습니다.
  Future<LocalCalendarStatus> refreshConnection() async {
    if (!_store.permissionGranted) {
      return _buildStatus();
    }

    final now = DateTime.now();
    final nextStart = DateTime(now.year, now.month, now.day, 19, 0);
    final adjustedNext = nextStart.isBefore(now)
        ? nextStart.add(const Duration(days: 1))
        : nextStart;

    _store.applyPreview(
      todayEventCount: 2,
      nextEventTitle: '저녁 약속',
      nextEventStartAt: adjustedNext,
      checkedAt: now,
    );

    return _buildStatus();
  }

  Future<LocalCalendarStatus> disconnect() async {
    _store.clear();
    return _buildStatus();
  }

  LocalCalendarStatus _buildStatus() {
    return LocalCalendarStatus(
      isConnected: _store.isConnected,
      permissionGranted: _store.permissionGranted,
      lastCheckedAt: _store.lastCheckedAt,
      todayEventCount: _store.todayEventCount,
      nextEventTitle: _store.nextEventTitle,
      nextEventStartAt: _store.nextEventStartAt,
    );
  }
}
