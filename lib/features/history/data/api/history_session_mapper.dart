import '../../../measure/data/model/measure_result_record.dart';
import '../model/care_status.dart';
import '../model/refresh_history_record.dart';

/// `REFRESH_SESSIONS` 행 + `REFRESH_MODE` 메타 → [RefreshHistoryRecord] 변환.
class HistorySessionMapper {
  const HistorySessionMapper._();

  static const sessionColumns =
      'session_id, mode_id, measure_id, started_at, duration_time, '
      'pollution_score_before, pollution_score_after, '
      'dust_score_before, dust_score_after, odor_score_before, odor_score_after';

  static const sessionColumnsWithoutMeasureId =
      'session_id, mode_id, started_at, duration_time, '
      'pollution_score_before, pollution_score_after, '
      'dust_score_before, dust_score_after, odor_score_before, odor_score_after';

  static RefreshHistoryRecord fromSessionRow({
    required Map<String, dynamic> session,
    required Map<String, dynamic>? mode,
    Map<String, dynamic>? measure,
  }) {
    final startedAtRaw = session['started_at'];
    final startedAt = startedAtRaw is String
        ? DateTime.parse(startedAtRaw)
        : DateTime.fromMillisecondsSinceEpoch(0);

    final durationSeconds = (session['duration_time'] as num?)?.round();
    final measureRecord = measure == null
        ? null
        : MeasureResultRecord.fromJson(measure);

    final odorBefore = _readOdorBefore(session, measureRecord);
    final odorAfter = _readOdorAfter(session, odorBefore);
    final dustBefore = _readDustBefore(session, measureRecord);
    final dustAfter = _readDustAfter(session, dustBefore);

    final odorYn = mode?['odor_yn'] == true;
    final dustYn = mode?['dust_yn'] == true;
    final scentYn = mode?['scent_yn'] == true;

    return RefreshHistoryRecord(
      dateTime: startedAt.toLocal(),
      modeName: mode?['display_name'] as String? ?? '리프레시',
      careType: _resolveCareType(
        odorYn: odorYn,
        dustYn: dustYn,
        scentYn: scentYn,
      ),
      duration: durationSeconds == null || durationSeconds <= 0
          ? null
          : Duration(seconds: durationSeconds),
      necessityReductionPercent: _averageImprovement(
        odorBefore: odorBefore,
        odorAfter: odorAfter,
        dustBefore: dustBefore,
        dustAfter: dustAfter,
      ),
      odorBeforeStatus: odorYn ? fromPollutionScore(odorBefore) : null,
      odorAfterStatus: odorYn ? fromPollutionScore(odorAfter) : null,
      dustBeforeStatus: dustYn ? fromPollutionScore(dustBefore) : null,
      dustAfterStatus: dustYn ? fromPollutionScore(dustAfter) : null,
    );
  }

  /// 오염 점수(0–100, 높을수록 관리 필요) → 케어 상태.
  static CareStatus? fromPollutionScore(int? score) {
    if (score == null) {
      return null;
    }
    if (score <= 25) {
      return CareStatus.good;
    }
    if (score <= 45) {
      return CareStatus.normal;
    }
    if (score <= 65) {
      return CareStatus.recommend;
    }
    if (score <= 85) {
      return CareStatus.focusedRecommend;
    }
    return CareStatus.focusedRequired;
  }

  static CareType _resolveCareType({
    required bool odorYn,
    required bool dustYn,
    required bool scentYn,
  }) {
    if (odorYn && dustYn) {
      return CareType.both;
    }
    if (odorYn) {
      return CareType.odor;
    }
    if (dustYn) {
      return CareType.dust;
    }
    if (scentYn) {
      return CareType.odor;
    }
    return CareType.both;
  }

  static int? _readOdorBefore(
    Map<String, dynamic> session,
    MeasureResultRecord? measure,
  ) {
    return _readScore(session, 'odor_score_before') ??
        _readScore(session, 'hair_odor_score_before') ??
        measure?.hairOdorScore;
  }

  static int? _readOdorAfter(Map<String, dynamic> session, int? odorBefore) {
    return _readScore(session, 'odor_score_after') ??
        _readScore(session, 'hair_odor_score_after');
  }

  static int? _readDustBefore(
    Map<String, dynamic> session,
    MeasureResultRecord? measure,
  ) {
    return _readScore(session, 'dust_score_before') ??
        _readScore(session, 'hair_dust_score_before') ??
        measure?.hairDustScore;
  }

  static int? _readDustAfter(Map<String, dynamic> session, int? dustBefore) {
    return _readScore(session, 'dust_score_after') ??
        _readScore(session, 'hair_dust_score_after');
  }

  static int? _readScore(Map<String, dynamic> row, String field) {
    final value = row[field];
    if (value is num) {
      return value.round();
    }
    return null;
  }

  static double? _improvementPercent(int? before, int? after) {
    if (before == null || after == null || before <= 0) {
      return null;
    }
    final delta = ((before - after) / before) * 100;
    if (delta.isNaN || delta.isInfinite) {
      return null;
    }
    return delta.clamp(0, 100);
  }

  static double? _averageImprovement({
    required int? odorBefore,
    required int? odorAfter,
    required int? dustBefore,
    required int? dustAfter,
  }) {
    final values = <double>[
      ?_improvementPercent(odorBefore, odorAfter),
      ?_improvementPercent(dustBefore, dustAfter),
    ];
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }
}
