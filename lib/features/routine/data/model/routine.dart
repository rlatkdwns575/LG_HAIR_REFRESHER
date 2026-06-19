/// 사용자가 등록한 리프레시 추천 알림.
///
/// 기기 로컬(SharedPreferences)에 저장되며 [weekdays]는 `DateTime.weekday`(1=월~7=일)를 따릅니다.
class Routine {
  const Routine({
    this.id,
    this.modeId,
    this.modeName,
    this.weekdays = const {},
    required this.hour,
    required this.minute,
    this.enabled = true,
    this.isRepeating = true,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? modeId;

  /// 화면 표시용 모드 이름.
  final String? modeName;

  /// 알림 요일.
  final Set<int> weekdays;

  final int hour;
  final int minute;
  final bool enabled;

  /// true면 매주 반복, false면 다음 해당 요일·시간에 한 번만 알림.
  final bool isRepeating;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isPersisted => id != null;

  String get timeLabel => RoutineWeekday.formatTime(hour, minute);

  String get weekdaysLabel {
    final sorted = weekdays.toList()..sort();
    return sorted.map(RoutineWeekday.shortLabel).join('·');
  }

  String get scheduleLabel {
    if (weekdays.isEmpty) {
      return timeLabel;
    }
    if (!isRepeating) {
      return '$weekdaysLabel · $timeLabel · 1회';
    }
    return '$weekdaysLabel · $timeLabel';
  }

  Routine copyWith({
    String? id,
    String? modeId,
    String? modeName,
    Set<int>? weekdays,
    int? hour,
    int? minute,
    bool? enabled,
    bool? isRepeating,
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
      isRepeating: isRepeating ?? this.isRepeating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    final time = (json['alarm_time'] as String?) ?? '09:00:00';
    final parts = time.split(':');
    final hour =
        json['hour'] as int? ??
        int.tryParse(parts.isNotEmpty ? parts[0] : '') ??
        9;
    final minute =
        json['minute'] as int? ??
        int.tryParse(parts.length > 1 ? parts[1] : '') ??
        0;

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
      id: (json['id'] ?? json['alarm_id']) as String?,
      modeId: json['mode_id'] as String?,
      modeName: json['mode_name'] as String?,
      weekdays: weekdays,
      hour: hour,
      minute: minute,
      enabled: (json['is_enabled'] as bool?) ?? true,
      isRepeating: (json['is_repeating'] as bool?) ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse('${json['created_at']}'),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse('${json['updated_at']}'),
    );
  }

  Map<String, dynamic> toJson() {
    final sortedDays = weekdays.toList()..sort();
    return {
      if (id != null) 'id': id,
      'mode_id': modeId,
      if (modeName != null) 'mode_name': modeName,
      'repeat_days': sortedDays,
      'hour': hour,
      'minute': minute,
      'alarm_time': '${RoutineWeekday.formatClock(hour, minute)}:00',
      'is_enabled': enabled,
      'is_repeating': isRepeating,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// 요일 표기/시간 포맷 헬퍼.
class RoutineWeekday {
  const RoutineWeekday._();

  static const ordered = [1, 2, 3, 4, 5, 6, 7];

  static const _shortLabels = ['월', '화', '수', '목', '금', '토', '일'];

  static String shortLabel(int weekday) {
    if (weekday < 1 || weekday > 7) {
      return '';
    }
    return _shortLabels[weekday - 1];
  }

  static String formatClock(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

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
