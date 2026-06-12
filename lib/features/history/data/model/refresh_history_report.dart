import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import 'care_status.dart';
import 'refresh_history_record.dart';

/// 반복 사용 패턴 기반 루틴 추천 카드 데이터.
class RoutineSuggestion {
  const RoutineSuggestion({
    required this.title,
    required this.subtitle,
    required this.tags,
  });

  final String title;
  final String subtitle;
  final List<String> tags;
}

/// 하루 단위로 묶은 리프레시 기록 + 요약 메시지.
class RefreshDayGroup {
  const RefreshDayGroup({
    required this.date,
    required this.records,
    required this.summaryMessage,
  });

  final DateTime date;
  final List<RefreshHistoryRecord> records;
  final String summaryMessage;

  int get count => records.length;
}

/// 가로 막대 통계 한 줄.
class HistoryBarStat {
  const HistoryBarStat({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final double percent;
  final Color color;
}

/// 시간대별 사용 횟수 (도넛/리스트 공용).
class TimeRangeUsage {
  const TimeRangeUsage({
    required this.count,
    required this.label,
    required this.color,
    required this.startHour,
    required this.endHour,
  });

  final int count;
  final String label;
  final Color color;

  /// 24시간 기준 시작 시각 (0–23).
  final int startHour;

  /// 24시간 기준 종료 시각 (startHour 초과, 최대 24).
  final int endHour;
}

/// 모드별 사용 횟수 + 개선도.
class ModeUsage {
  const ModeUsage({
    required this.count,
    required this.modeName,
    required this.improvementPercent,
  });

  final int count;
  final String modeName;
  final double improvementPercent;
}

/// 인사이트 카드 (제목 + 설명들 + 막대).
class HistoryInsight {
  const HistoryInsight({
    required this.title,
    required this.descriptions,
    this.bars = const [],
  });

  final String title;
  final List<String> descriptions;
  final List<HistoryBarStat> bars;
}

/// 월간 요약.
class RefreshMonthlySummary {
  const RefreshMonthlySummary({
    required this.month,
    required this.totalCount,
    required this.vsLastMonthDelta,
    required this.improvementPercent,
    required this.improvementDeltaPercent,
    required this.mostUsedMode,
    required this.mostUsedTimeRange,
  });

  final DateTime month;
  final int totalCount;
  final int vsLastMonthDelta;
  final double improvementPercent;
  final double improvementDeltaPercent;
  final String mostUsedMode;
  final String mostUsedTimeRange;
}

/// 전체 누적 인사이트.
class RefreshTotalSummary {
  const RefreshTotalSummary({
    required this.introMessage,
    required this.totalCount,
    required this.averageImprovementPercent,
    required this.preStatePattern,
    required this.timeUsage,
    required this.timeUsageInsight,
    required this.careRatio,
    required this.modeUsageDescription,
    required this.modeUsages,
  });

  final String introMessage;
  final int totalCount;
  final double averageImprovementPercent;
  final HistoryInsight preStatePattern;
  final List<TimeRangeUsage> timeUsage;
  final HistoryInsight timeUsageInsight;
  final HistoryInsight careRatio;
  final String modeUsageDescription;
  final List<ModeUsage> modeUsages;

  /// 가장 개선도가 높은 모드 (해당 항목 강조용).
  ModeUsage? get bestImprovementMode {
    if (modeUsages.isEmpty) {
      return null;
    }
    return modeUsages.reduce(
      (a, b) => a.improvementPercent >= b.improvementPercent ? a : b,
    );
  }
}

/// 리프레시 기록 리포트 전체 데이터.
class RefreshHistoryReport {
  const RefreshHistoryReport({
    required this.asOfDate,
    required this.userName,
    required this.todayRecords,
    required this.todaySummaryTitle,
    required this.todaySummarySubtitle,
    required this.routineSuggestion,
    required this.month,
    required this.dayGroups,
    required this.monthlySummary,
    required this.totalSummary,
  });

  final DateTime asOfDate;
  final String userName;

  final List<RefreshHistoryRecord> todayRecords;
  final String todaySummaryTitle;
  final String todaySummarySubtitle;
  final RoutineSuggestion? routineSuggestion;

  final DateTime month;
  final List<RefreshDayGroup> dayGroups;
  final RefreshMonthlySummary monthlySummary;
  final RefreshTotalSummary totalSummary;

  bool get hasTodayRecords => todayRecords.isNotEmpty;

  /// 날짜별 기록 수 (캘린더 도트 표시용).
  Map<DateTime, int> get countByDate {
    return {for (final group in dayGroups) group.date: group.count};
  }

  RefreshDayGroup? groupForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    for (final group in dayGroups) {
      if (group.date == key) {
        return group;
      }
    }
    return null;
  }

  /// 가장 최근 기록이 있는 날짜 (기본 선택용).
  DateTime? get latestRecordedDate {
    if (dayGroups.isEmpty) {
      return null;
    }
    return dayGroups
        .map((group) => group.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  static DateTime _at(int day, int hour, int minute) =>
      DateTime(2026, 6, day, hour, minute);

  /// Figma 리프레시 기록 리포트 기준 mock. API 연동 시 교체합니다.
  static final RefreshHistoryReport sample = RefreshHistoryReport(
    asOfDate: DateTime(2026, 6, 11),
    userName: '제이',
    todaySummaryTitle: '오늘 2회 리프레시 했어요',
    todaySummarySubtitle: '최근 리프레시 후 안심 가능한 상태로 회복됐어요',
    todayRecords: [
      RefreshHistoryRecord(
        dateTime: _at(11, 11, 42),
        modeName: '리프레시 모드 이름',
        careType: CareType.both,
        duration: const Duration(minutes: 5),
        necessityReductionPercent: 76,
        odorBeforeStatus: CareStatus.focusedRecommend,
        odorAfterStatus: CareStatus.good,
        dustBeforeStatus: CareStatus.focusedRequired,
        dustAfterStatus: CareStatus.normal,
      ),
      RefreshHistoryRecord(
        dateTime: _at(11, 14, 12),
        modeName: '리프레시 모드 이름',
        careType: CareType.both,
        duration: const Duration(minutes: 5),
        necessityReductionPercent: 76,
        odorBeforeStatus: CareStatus.focusedRequired,
        odorAfterStatus: CareStatus.good,
        dustBeforeStatus: CareStatus.focusedRequired,
        dustAfterStatus: CareStatus.good,
      ),
    ],
    routineSuggestion: const RoutineSuggestion(
      title: '반복적인 사용 패턴이 발견되었어요.',
      subtitle: '새로운 루틴으로 등록할까요?',
      tags: ['퇴근 후 리프레시 케어', '수요일·금요일', '오후 7시', '5분 소요'],
    ),
    month: DateTime(2026, 6),
    dayGroups: [
      RefreshDayGroup(
        date: DateTime(2026, 6, 3),
        summaryMessage: '외부 냄새와 먼지가 함께 많이 감지된 날이에요.',
        records: [
          RefreshHistoryRecord(
            dateTime: _at(3, 22, 42),
            modeName: '리프레시 모드 이름',
            careType: CareType.both,
            necessityReductionPercent: 72,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.focusedRequired,
            dustAfterStatus: CareStatus.good,
          ),
        ],
      ),
      RefreshDayGroup(
        date: DateTime(2026, 6, 6),
        summaryMessage: '냄새관리에 집중했던 날이에요.',
        records: [
          RefreshHistoryRecord(
            dateTime: _at(6, 9, 12),
            modeName: '리프레시 모드 이름',
            careType: CareType.odor,
            necessityReductionPercent: 64,
            odorBeforeStatus: CareStatus.recommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.normal,
            dustAfterStatus: CareStatus.good,
          ),
          RefreshHistoryRecord(
            dateTime: _at(6, 20, 5),
            modeName: '외부 냄새 리프레시',
            careType: CareType.odor,
            necessityReductionPercent: 70,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.normal,
            dustAfterStatus: CareStatus.good,
          ),
        ],
      ),
      RefreshDayGroup(
        date: DateTime(2026, 6, 7),
        summaryMessage: '먼지관리에 집중했던 날이에요.',
        records: [
          RefreshHistoryRecord(
            dateTime: _at(7, 8, 30),
            modeName: '리프레시 모드 이름',
            careType: CareType.dust,
            necessityReductionPercent: 58,
            odorBeforeStatus: CareStatus.normal,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.focusedRequired,
            dustAfterStatus: CareStatus.good,
          ),
          RefreshHistoryRecord(
            dateTime: _at(7, 19, 40),
            modeName: '리프레시 모드 이름',
            careType: CareType.dust,
            necessityReductionPercent: 61,
            odorBeforeStatus: CareStatus.recommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.focusedRequired,
            dustAfterStatus: CareStatus.good,
          ),
        ],
      ),
      RefreshDayGroup(
        date: DateTime(2026, 6, 8),
        summaryMessage: '냄새와 먼지를 함께 케어한 날이에요.',
        records: [
          RefreshHistoryRecord(
            dateTime: _at(8, 21, 15),
            modeName: '외부 냄새 리프레시',
            careType: CareType.both,
            necessityReductionPercent: 73,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.focusedRequired,
            dustAfterStatus: CareStatus.good,
          ),
        ],
      ),
      RefreshDayGroup(
        date: DateTime(2026, 6, 9),
        summaryMessage: '냄새관리에 집중했던 날이에요.',
        records: [
          RefreshHistoryRecord(
            dateTime: _at(9, 7, 20),
            modeName: '리프레시 모드 이름',
            careType: CareType.odor,
            necessityReductionPercent: 55,
            odorBeforeStatus: CareStatus.recommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.normal,
            dustAfterStatus: CareStatus.good,
          ),
          RefreshHistoryRecord(
            dateTime: _at(9, 12, 0),
            modeName: '외부 냄새 리프레시',
            careType: CareType.odor,
            necessityReductionPercent: 67,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.normal,
            dustAfterStatus: CareStatus.good,
          ),
          RefreshHistoryRecord(
            dateTime: _at(9, 20, 30),
            modeName: '외부 냄새 리프레시',
            careType: CareType.odor,
            necessityReductionPercent: 71,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.normal,
            dustAfterStatus: CareStatus.good,
          ),
        ],
      ),
      RefreshDayGroup(
        date: DateTime(2026, 6, 10),
        summaryMessage: '먼지관리에 집중했던 날이에요.',
        records: [
          RefreshHistoryRecord(
            dateTime: _at(10, 23, 12),
            modeName: '헤어 상태 진단',
            careType: CareType.diagnosis,
            isDiagnosis: true,
            odorBeforeStatus: CareStatus.notNeeded,
            dustBeforeStatus: CareStatus.notNeeded,
          ),
          RefreshHistoryRecord(
            dateTime: _at(10, 19, 38),
            modeName: '리프레시 모드 이름',
            careType: CareType.both,
            necessityReductionPercent: 74,
            odorBeforeStatus: CareStatus.focusedRecommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.focusedRequired,
            dustAfterStatus: CareStatus.good,
          ),
          RefreshHistoryRecord(
            dateTime: _at(10, 11, 42),
            modeName: '리프레시 모드 이름',
            careType: CareType.both,
            necessityReductionPercent: 69,
            odorBeforeStatus: CareStatus.recommend,
            odorAfterStatus: CareStatus.good,
            dustBeforeStatus: CareStatus.focusedRequired,
            dustAfterStatus: CareStatus.good,
          ),
        ],
      ),
    ],
    monthlySummary: RefreshMonthlySummary(
      month: DateTime(2026, 6),
      totalCount: 12,
      vsLastMonthDelta: 3,
      improvementPercent: 67,
      improvementDeltaPercent: 4,
      mostUsedMode: '외부 냄새 리프레시',
      mostUsedTimeRange: '오후 7시~10시',
    ),
    totalSummary: RefreshTotalSummary(
      introMessage: '리프레시가 점점 {이름}님의\n외출 후 루틴으로 자리 잡고 있어요.',
      totalCount: 100,
      averageImprovementPercent: 80,
      preStatePattern: const HistoryInsight(
        title: '리프레시 전 상태 패턴',
        descriptions: [
          '리프레시 전에는 냄새 높음 상태가 자주 감지됐어요',
          '냄새와 먼지 흔적이 함께 감지된 날이 많았어요.',
        ],
        bars: [
          HistoryBarStat(
            label: '냄새 높음',
            percent: 90,
            color: AppColors.orange600,
          ),
          HistoryBarStat(
            label: '먼지 높음',
            percent: 10,
            color: AppColors.primary300,
          ),
        ],
      ),
      timeUsageInsight: const HistoryInsight(
        title: '자주 사용한 시간대',
        descriptions: [
          '오후 7시~10시에 리프레시를 자주 했어요',
          '하루 동안 쌓인 외부 흔적을 덜어내는 루틴으로 사용했어요.',
        ],
      ),
      timeUsage: const [
        TimeRangeUsage(
          count: 80,
          label: '오후 7시~10시',
          color: AppColors.primary500,
          startHour: 19,
          endHour: 22,
        ),
        TimeRangeUsage(
          count: 14,
          label: '오후 12시~2시',
          color: AppColors.primary400,
          startHour: 12,
          endHour: 14,
        ),
        TimeRangeUsage(
          count: 6,
          label: '오후 6~7시',
          color: AppColors.primary300,
          startHour: 18,
          endHour: 19,
        ),
      ],
      careRatio: const HistoryInsight(
        title: '주요 케어 비중',
        descriptions: ['냄새 중심의 케어를 가장 많이 사용했어요'],
        bars: [
          HistoryBarStat(
            label: '냄새 케어',
            percent: 90,
            color: AppColors.primary500,
          ),
          HistoryBarStat(label: '먼지 케어', percent: 10, color: AppColors.blue700),
        ],
      ),
      modeUsageDescription: '000000모드를 가장 많이 사용했어요',
      modeUsages: [
        ModeUsage(count: 56, modeName: '000000모드', improvementPercent: 70),
        ModeUsage(count: 12, modeName: '000000모드', improvementPercent: 86),
        ModeUsage(count: 3, modeName: '000000모드', improvementPercent: 50),
      ],
    ),
  );

  /// 오늘 기록이 없는 빈 상태 mock.
  static final RefreshHistoryReport emptyTodaySample = RefreshHistoryReport(
    asOfDate: sample.asOfDate,
    userName: sample.userName,
    todaySummaryTitle: sample.todaySummaryTitle,
    todaySummarySubtitle: sample.todaySummarySubtitle,
    todayRecords: const [],
    routineSuggestion: sample.routineSuggestion,
    month: sample.month,
    dayGroups: sample.dayGroups,
    monthlySummary: sample.monthlySummary,
    totalSummary: sample.totalSummary,
  );
}
