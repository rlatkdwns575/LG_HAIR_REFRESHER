import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/history/data/api/history_report_builder.dart';
import 'package:lg_hair_refresher/features/history/data/api/history_session_mapper.dart';
import 'package:lg_hair_refresher/features/history/data/model/care_status.dart';
import 'package:lg_hair_refresher/features/history/data/model/refresh_history_record.dart';

void main() {
  group('HistorySessionMapper', () {
    test('maps pollution score to care status', () {
      expect(HistorySessionMapper.fromPollutionScore(20), CareStatus.good);
      expect(HistorySessionMapper.fromPollutionScore(40), CareStatus.normal);
      expect(HistorySessionMapper.fromPollutionScore(60), CareStatus.recommend);
      expect(
        HistorySessionMapper.fromPollutionScore(80),
        CareStatus.focusedRecommend,
      );
      expect(
        HistorySessionMapper.fromPollutionScore(95),
        CareStatus.focusedRequired,
      );
    });

    test('maps session row with mode metadata', () {
      final record = HistorySessionMapper.fromSessionRow(
        session: {
          'started_at': '2026-06-09T11:20:00.000Z',
          'duration_time': 300,
          'odor_score_before': 78,
          'odor_score_after': 24,
          'dust_score_before': 52,
          'dust_score_after': 20,
        },
        mode: {'display_name': '외부 냄새 리프레시', 'odor_yn': true, 'dust_yn': true},
      );

      expect(record.modeName, '외부 냄새 리프레시');
      expect(record.careType, CareType.both);
      expect(record.duration, const Duration(seconds: 300));
      expect(record.odorBeforeStatus, CareStatus.focusedRecommend);
      expect(record.odorAfterStatus, CareStatus.good);
      expect(record.necessityReductionPercent, isNotNull);
    });
  });

  group('HistoryReportBuilder', () {
    test('builds today and monthly summaries from records', () {
      final report = HistoryReportBuilder.build(
        userName: '제이',
        asOfDate: DateTime(2026, 6, 11),
        records: [
          RefreshHistoryRecord(
            dateTime: DateTime(2026, 6, 11, 11, 42),
            modeName: '외부 냄새 리프레시',
            careType: CareType.both,
            necessityReductionPercent: 76,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.recommend,
            dustAfterStatus: CareStatus.good,
          ),
          RefreshHistoryRecord(
            dateTime: DateTime(2026, 6, 9, 20, 30),
            modeName: '외부 냄새 리프레시',
            careType: CareType.odor,
            necessityReductionPercent: 71,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
          ),
        ],
      );

      expect(report.userName, '제이');
      expect(report.todayRecords, hasLength(1));
      expect(report.todaySummaryTitle, '오늘 1회 리프레시 했어요');
      expect(report.monthHistory, isNotEmpty);
      expect(report.totalSummary.totalCount, 2);
      expect(
        report.monthDataFor(DateTime(2026, 6)).monthlySummary.totalCount,
        2,
      );
    });
  });
}
