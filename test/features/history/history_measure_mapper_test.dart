import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/history/data/api/history_measure_mapper.dart';
import 'package:lg_hair_refresher/features/history/data/api/history_session_mapper.dart';
import 'package:lg_hair_refresher/features/history/data/model/care_status.dart';
import 'package:lg_hair_refresher/features/history/data/model/refresh_history_record.dart';

void main() {
  group('HistoryMeasureMapper', () {
    test('maps MEASURE_RESULTS row to diagnosis record', () {
      final record = HistoryMeasureMapper.fromMeasureRow({
        'measure_id': 'm-1',
        'user_device_id': 'ud-1',
        'hair_dust_score': 72,
        'hair_odor_score': 81,
        'total_pollution_score': 81,
        'hair_damage_score': 'Medium',
        'hair_thickness': '중간',
        'hair_sebum': 'High',
        'smell_type': '음식,땀',
        'created_at': '2026-06-11T09:30:00.000Z',
      });

      expect(record.isDiagnosis, isTrue);
      expect(record.careType, CareType.diagnosis);
      expect(record.modeName, '헤어 상태 진단');
      expect(record.odorBeforeStatus, CareStatus.focusedRecommend);
      expect(record.dustBeforeStatus, CareStatus.focusedRecommend);
      expect(record.resultMessage, contains('81'));
      expect(record.resultMessage, contains('음식,땀'));
    });
  });

  group('HistorySessionMapper measure fallback', () {
    test(
      'uses linked MEASURE_RESULTS scores when session before is missing',
      () {
        final record = HistorySessionMapper.fromSessionRow(
          session: {
            'started_at': '2026-06-11T10:00:00.000Z',
            'duration_time': 300,
            'measure_id': 'm-1',
            'odor_score_after': 20,
            'dust_score_after': 18,
          },
          mode: {
            'display_name': '외출 후 리프레시',
            'odor_yn': true,
            'dust_yn': true,
            'scent_yn': false,
          },
          measure: {
            'measure_id': 'm-1',
            'user_device_id': 'ud-1',
            'hair_dust_score': 70,
            'hair_odor_score': 80,
            'total_pollution_score': 80,
            'created_at': '2026-06-11T09:30:00.000Z',
          },
        );

        expect(record.modeName, '외출 후 리프레시');
        expect(record.odorBeforeStatus, CareStatus.focusedRecommend);
        expect(record.odorAfterStatus, CareStatus.good);
        expect(record.dustBeforeStatus, CareStatus.focusedRecommend);
        expect(record.necessityReductionPercent, isNotNull);
      },
    );
  });
}
