/// 로컬 캘린더 연동 세션 저장소.
///
/// MVP 단계에서는 기기 캘린더 API 연동 전, 사용자 동의·상태 확인 흐름을
/// 앱 세션 안에서 유지합니다.
class LocalCalendarConnectionStore {
  LocalCalendarConnectionStore._();

  static final LocalCalendarConnectionStore instance =
      LocalCalendarConnectionStore._();

  bool permissionGranted = false;
  bool isConnected = false;
  DateTime? lastCheckedAt;
  int todayEventCount = 0;
  String? nextEventTitle;
  DateTime? nextEventStartAt;

  void grantPermission() {
    permissionGranted = true;
  }

  void applyPreview({
    required int todayEventCount,
    required String nextEventTitle,
    required DateTime nextEventStartAt,
    required DateTime checkedAt,
  }) {
    this.todayEventCount = todayEventCount;
    this.nextEventTitle = nextEventTitle;
    this.nextEventStartAt = nextEventStartAt;
    lastCheckedAt = checkedAt;
    isConnected = true;
  }

  void clear() {
    permissionGranted = false;
    isConnected = false;
    lastCheckedAt = null;
    todayEventCount = 0;
    nextEventTitle = null;
    nextEventStartAt = null;
  }
}
