/// 로컬 캘린더 연동 상태 요약.
class LocalCalendarStatus {
  const LocalCalendarStatus({
    required this.isConnected,
    required this.permissionGranted,
    this.lastCheckedAt,
    this.todayEventCount = 0,
    this.nextEventTitle,
    this.nextEventStartAt,
    this.deviceCalendarCount = 0,
    this.deviceRawEventCount = 0,
    this.lastFetchNote,
  });

  final bool isConnected;
  final bool permissionGranted;
  final DateTime? lastCheckedAt;
  final int todayEventCount;
  final String? nextEventTitle;
  final DateTime? nextEventStartAt;
  final int deviceCalendarCount;
  final int deviceRawEventCount;
  final String? lastFetchNote;

  static const disconnected = LocalCalendarStatus(
    isConnected: false,
    permissionGranted: false,
  );

  String get listRightLabel => isConnected ? '연동됨' : '미연동';

  String get permissionLabel {
    if (!permissionGranted) {
      return '미허용';
    }
    return '허용됨';
  }

  String get connectionLabel => isConnected ? '연동됨' : '연동 안 됨';

  String get lastCheckedLabel {
    if (lastCheckedAt == null) {
      return '—';
    }
    final value = lastCheckedAt!;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.month}월 ${value.day}일 $hour:$minute';
  }

  String get deviceFetchLabel {
    if (!permissionGranted) {
      return '—';
    }
    return '캘린더 $deviceCalendarCount개 · 원본 $deviceRawEventCount건';
  }

  String get nextEventLabel {
    if (!isConnected || nextEventTitle == null || nextEventStartAt == null) {
      return '—';
    }
    final start = nextEventStartAt!;
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$nextEventTitle · $hour:$minute';
  }

  String get statusMessage {
    if (!permissionGranted) {
      return '기기 캘린더 접근 권한이 필요합니다. 연동하기를 눌러 권한을 허용해 주세요.';
    }
    if (!isConnected) {
      return '권한은 허용되었지만 아직 일정을 확인하지 않았습니다. 상태 확인을 눌러 연동을 검증해 주세요.';
    }
    if (todayEventCount == 0 && deviceRawEventCount > 0) {
      return '기기에서 $deviceRawEventCount건을 읽었지만 오늘 일정으로 분류된 항목이 없습니다. '
          '일정이 오늘 날짜인지 확인해 주세요.';
    }
    if (todayEventCount == 0 && deviceCalendarCount == 0) {
      return '기기 캘린더 목록을 불러오지 못했습니다. 앱 권한에서 캘린더(읽기/쓰기)를 허용했는지 확인해 주세요.';
    }
    if (todayEventCount == 0) {
      return '기기 캘린더 $deviceCalendarCount개를 확인했지만 오늘 일정이 없습니다.';
    }
    return '로컬 캘린더 연동이 정상입니다. 오늘 일정 $todayEventCount건을 확인했습니다.';
  }
}
