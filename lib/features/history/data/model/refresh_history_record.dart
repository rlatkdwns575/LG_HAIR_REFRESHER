import 'care_status.dart';

/// 케어 집중 유형 (요약 메시지·통계 계산용).
enum CareType {
  diagnosis('진단'),
  odor('냄새관리'),
  dust('먼지관리'),
  both('냄새·먼지 관리');

  const CareType(this.label);

  final String label;
}

/// 단일 리프레시(또는 진단) 기록.
///
/// Supabase 연동 시 [fromJson] 으로 교체할 수 있도록 필드를 분리했습니다.
class RefreshHistoryRecord {
  const RefreshHistoryRecord({
    required this.dateTime,
    required this.modeName,
    required this.careType,
    this.duration,
    this.necessityReductionPercent,
    this.odorBeforeStatus,
    this.odorAfterStatus,
    this.dustBeforeStatus,
    this.dustAfterStatus,
    this.resultMessage,
    this.isDiagnosis = false,
  });

  /// 측정/리프레시가 일어난 시각 (날짜 + 시간).
  final DateTime dateTime;
  final String modeName;
  final CareType careType;
  final Duration? duration;

  /// 리프레시 필요성 감소율 (예: 76 → "76% 감소").
  final double? necessityReductionPercent;

  final CareStatus? odorBeforeStatus;
  final CareStatus? odorAfterStatus;
  final CareStatus? dustBeforeStatus;
  final CareStatus? dustAfterStatus;

  /// 기록 요약 메시지 (선택).
  final String? resultMessage;

  /// 리프레시가 아닌 헤어 상태 진단 기록 여부.
  final bool isDiagnosis;

  /// 날짜만 (시간 0으로 정규화) — 캘린더 그룹핑 키.
  DateTime get dateKey => DateTime(dateTime.year, dateTime.month, dateTime.day);

  bool get hasNecessityReduction => necessityReductionPercent != null;

  String? get necessityReductionLabel {
    final value = necessityReductionPercent;
    if (value == null) {
      return null;
    }
    if (value == value.roundToDouble()) {
      return '${value.toInt()}% 감소';
    }
    return '${value.toStringAsFixed(1)}% 감소';
  }

  factory RefreshHistoryRecord.fromJson(Map<String, dynamic> json) {
    final durationSeconds = json['duration_seconds'] as int?;
    return RefreshHistoryRecord(
      dateTime: DateTime.parse(json['measured_at'] as String),
      modeName: json['mode_name'] as String? ?? '리프레시',
      careType: CareType.values.firstWhere(
        (type) => type.name == json['care_type'],
        orElse: () => CareType.both,
      ),
      duration: durationSeconds == null
          ? null
          : Duration(seconds: durationSeconds),
      necessityReductionPercent: (json['necessity_reduction_percent'] as num?)
          ?.toDouble(),
      odorBeforeStatus: CareStatus.fromCode(json['odor_before'] as String?),
      odorAfterStatus: CareStatus.fromCode(json['odor_after'] as String?),
      dustBeforeStatus: CareStatus.fromCode(json['dust_before'] as String?),
      dustAfterStatus: CareStatus.fromCode(json['dust_after'] as String?),
      resultMessage: json['result_message'] as String?,
      isDiagnosis: json['is_diagnosis'] as bool? ?? false,
    );
  }
}
