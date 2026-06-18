/// 사용자가 등록한 리프레시 추천 알림.
///
/// `REFRESH_RECOMMEND_ALARMS` 테이블과 매핑됩니다.
/// [weekdays]는 `repeat_days`(int2[])로 저장되며 `DateTime.weekday`(1=월~7=일)를 따릅니다.
class Routine {
  const Routine({
    this.id,
    this.modeId,
    this.modeName,
    this.weekdays = const {},
    required this.hour,
    required this.minute,
    this.enabled = true,
    this.createdAt,
    this.updatedAt,
  });

  /// `alarm_id`.
  final String? id;

  /// `mode_id` — 연결된 리프레시 모드.
  final String? modeId;

  /// 화면 표시용 모드 이름. DB에는 저장되지 않습니다.
  final String? modeName;

  /// `repeat_days` — 반복 요일.
  final Set<int> weekdays;

  final int hour;
  final int minute;

  /// `is_enabled`.
  final bool enabled;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPersisted => id != null;

  /// "오전 6시", "오후 7시 30분" 형태의 한국어 시간 라벨.
  String get timeLabel => RoutineWeekday.formatTime(hour, minute);

  /// "월·수·금" 형태의 선택 요일 라벨. 없으면 빈 문자열.
  String get weekdaysLabel {
    final sorted = weekdays.toList()..sort();
    return sorted.map(RoutineWeekday.shortLabel).join('·');
  }

  Routine copyWith({
    String? id,
    String? modeId,
    String? modeName,
    Set<int>? weekdays,
    int? hour,
    int? minute,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      modeId: modeId ?? this.modeId,
      modeName: modeName ?? this.modeName,
      weekdays: weekdays ?? this.weekdays,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    final time = (json['alarm_time'] as String?) ?? '09:00:00';
    final parts = time.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 9;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;

    final rawDays = json['repeat_days'];
    final weekdays = <int>{};
    if (rawDays is List) {
      for (final value in rawDays) {
        final day = value is int ? value : int.tryParse('$value');
        if (day != null && day >= 1 && day <= 7) {
          weekdays.add(day);
        }
      }
    }

    return Routine(
      id: json['alarm_id'] as String?,
      modeId: json['mode_id'] as String?,
      weekdays: weekdays,
      hour: hour,
      minute: minute,
      enabled: (json['is_enabled'] as bool?) ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse('${json['created_at']}'),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse('${json['updated_at']}'),
    );
  }

  /// insert/update 페이로드. `alarm_id`/`user_id`/타임스탬프는 API에서 처리합니다.
  Map<String, dynamic> toJson() {
    final sortedDays = weekdays.toList()..sort();
    return {
      'mode_id': modeId,
      'alarm_time': '${RoutineWeekday.formatClock(hour, minute)}:00',
      'repeat_days': sortedDays,
      'is_enabled': enabled,
    };
  }
}

/// 요일 표기/시간 포맷 헬퍼.
class RoutineWeekday {
  const RoutineWeekday._();

  /// 화면 표기 순서(월~일)에 맞춘 `DateTime.weekday` 값.
  static const ordered = [1, 2, 3, 4, 5, 6, 7];

  static const _shortLabels = ['월', '화', '수', '목', '금', '토', '일'];

  static String shortLabel(int weekday) {
    if (weekday < 1 || weekday > 7) {
      return '';
    }
    return _shortLabels[weekday - 1];
  }

  /// "HH:mm" 24시간 표기.
  static String formatClock(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// "오전 6시", "오후 7시 30분" 한국어 표기.
  static String formatTime(int hour, int minute) {
    final isAm = hour < 12;
    final period = isAm ? '오전' : '오후';
    var displayHour = hour % 12;
    if (displayHour == 0) {
      displayHour = 12;
    }
    final base = '$period $displayHour시';
    if (minute == 0) {
      return base;
    }
    return '$base ${minute.toString().padLeft(2, '0')}분';
  }
}

/// 모드 선택 드롭다운용 경량 옵션 (`REFRESH_MODE` 조회 결과).
class RoutineModeOption {
  const RoutineModeOption({required this.id, required this.name});

  final String id;
  final String name;
}
