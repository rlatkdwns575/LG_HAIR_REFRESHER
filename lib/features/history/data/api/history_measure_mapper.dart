import '../../../measure/data/model/measure_result_record.dart';
import '../model/refresh_history_record.dart';
import 'history_session_mapper.dart';

/// `MEASURE_RESULTS` 행 → [RefreshHistoryRecord] 변환.
class HistoryMeasureMapper {
  const HistoryMeasureMapper._();

  static const resultColumns =
      'measure_id, user_device_id, hair_dust_score, hair_odor_score, '
      'total_pollution_score, hair_damage_score, hair_thickness, '
      'hair_sebum, smell_type, created_at';

  static RefreshHistoryRecord fromMeasureRow(Map<String, dynamic> row) {
    final record = MeasureResultRecord.fromJson(row);

    return RefreshHistoryRecord(
      dateTime: record.createdAt.toLocal(),
      modeName: '헤어 상태 진단',
      careType: CareType.diagnosis,
      isDiagnosis: true,
      odorBeforeStatus: HistorySessionMapper.fromPollutionScore(
        record.hairOdorScore,
      ),
      dustBeforeStatus: HistorySessionMapper.fromPollutionScore(
        record.hairDustScore,
      ),
      resultMessage: _resultMessage(record),
    );
  }

  static String _resultMessage(MeasureResultRecord record) {
    final parts = <String>[
      '오염 점수 ${record.totalPollutionScore}',
      if (record.smellType != null && record.smellType!.isNotEmpty)
        '냄새 유형 ${record.smellType}',
    ];
    return parts.join(' · ');
  }
}
