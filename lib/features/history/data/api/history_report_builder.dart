import '../../../../app/theme/app_colors.dart';
import '../model/care_status.dart';
import '../model/refresh_history_record.dart';
import '../model/refresh_history_report.dart';

/// 세션 기록 목록 → 화면용 [RefreshHistoryReport] 집계.
class HistoryReportBuilder {
  const HistoryReportBuilder._();

  static const _timeBuckets = <_TimeBucket>[
    _TimeBucket(startHour: 6, endHour: 11, label: '오전 6시~11시'),
    _TimeBucket(startHour: 12, endHour: 14, label: '오후 12시~2시'),
    _TimeBucket(startHour: 15, endHour: 17, label: '오후 3시~5시'),
    _TimeBucket(startHour: 18, endHour: 19, label: '오후 6~7시'),
    _TimeBucket(startHour: 19, endHour: 22, label: '오후 7시~10시'),
    _TimeBucket(startHour: 22, endHour: 24, label: '밤 10시~'),
  ];

  static RefreshHistoryReport build({
    required List<RefreshHistoryRecord> records,
    required String userName,
    DateTime? asOfDate,
  }) {
    final asOf = _dateOnly(asOfDate ?? DateTime.now());
    final refreshRecords =
        records.where((record) => !record.isDiagnosis).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final todayRecords = refreshRecords
        .where((record) => _isSameDay(record.dateTime, asOf))
        .toList();

    final monthHistory = _buildMonthHistory(refreshRecords, asOf);
    final totalSummary = _buildTotalSummary(refreshRecords, userName);

    return RefreshHistoryReport(
      asOfDate: asOf,
      userName: userName,
      todayRecords: todayRecords,
      todaySummaryTitle: _todayTitle(todayRecords),
      todaySummarySubtitle: _todaySubtitle(todayRecords),
      routineSuggestion: _buildRoutineSuggestion(refreshRecords),
      monthHistory: monthHistory,
      totalSummary: totalSummary,
    );
  }

  static String _todayTitle(List<RefreshHistoryRecord> todayRecords) {
    if (todayRecords.isEmpty) {
      return '오늘은 아직 리프레시 기록이 없어요';
    }
    return '오늘 ${todayRecords.length}회 리프레시 했어요';
  }

  static String _todaySubtitle(List<RefreshHistoryRecord> todayRecords) {
    if (todayRecords.isEmpty) {
      return '리프레시를 시작하면 오늘의 케어 요약이 표시돼요';
    }
    final latest = todayRecords.first;
    final afterGood =
        latest.odorAfterStatus == CareStatus.good ||
        latest.dustAfterStatus == CareStatus.good;
    if (afterGood) {
      return '최근 리프레시 후 안심 가능한 상태로 회복됐어요';
    }
    return '오늘의 리프레시 기록을 확인해보세요';
  }

  static RoutineSuggestion? _buildRoutineSuggestion(
    List<RefreshHistoryRecord> records,
  ) {
    if (records.length < 3) {
      return null;
    }

    final bucketCounts = <String, int>{};
    final weekdayCounts = List<int>.filled(7, 0);
    for (final record in records) {
      final bucket = _bucketForHour(record.dateTime.hour);
      if (bucket != null) {
        bucketCounts[bucket.label] = (bucketCounts[bucket.label] ?? 0) + 1;
      }
      weekdayCounts[record.dateTime.weekday - 1]++;
    }

    final topBucket = _topEntry(bucketCounts);
    final topWeekdays = _topWeekdayLabels(weekdayCounts);
    if (topBucket == null) {
      return null;
    }

    final avgDuration = records
        .where((record) => record.duration != null)
        .map((record) => record.duration!.inMinutes)
        .fold<int>(0, (sum, minutes) => sum + minutes);
    final durationCount = records
        .where((record) => record.duration != null)
        .length;
    final durationLabel = durationCount == 0
        ? null
        : '${(avgDuration / durationCount).round()}분 소요';

    final tags = <String>[
      '퇴근 후 리프레시 케어',
      if (topWeekdays.isNotEmpty) topWeekdays,
      topBucket.key,
      ?durationLabel,
    ];

    return RoutineSuggestion(
      title: '반복적인 사용 패턴이 발견되었어요.',
      subtitle: '새로운 루틴으로 등록할까요?',
      tags: tags,
    );
  }

  static List<RefreshHistoryMonthData> _buildMonthHistory(
    List<RefreshHistoryRecord> records,
    DateTime asOf,
  ) {
    if (records.isEmpty) {
      return [RefreshHistoryMonthData.empty(DateTime(asOf.year, asOf.month))];
    }

    final earliest = records
        .map((record) => _monthKey(record.dateTime))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = DateTime(asOf.year, asOf.month);

    final months = <DateTime>[];
    var cursor = latest;
    while (!cursor.isBefore(earliest)) {
      months.add(cursor);
      cursor = RefreshHistoryReport.monthBefore(cursor);
    }

    final summariesByMonth = <DateTime, RefreshMonthlySummary>{};
    for (final month in months) {
      summariesByMonth[month] = _monthlySummary(
        records,
        month,
        summariesByMonth,
      );
    }

    return [
      for (final month in months)
        RefreshHistoryMonthData(
          month: month,
          dayGroups: _dayGroups(records, month),
          monthlySummary: summariesByMonth[month]!,
        ),
    ];
  }

  static List<RefreshDayGroup> _dayGroups(
    List<RefreshHistoryRecord> records,
    DateTime month,
  ) {
    final grouped = <DateTime, List<RefreshHistoryRecord>>{};
    for (final record in records) {
      if (!_isSameMonth(record.dateTime, month)) {
        continue;
      }
      final key = _dateOnly(record.dateTime);
      grouped.putIfAbsent(key, () => []).add(record);
    }

    final dates = grouped.keys.toList()..sort();
    return [
      for (final date in dates)
        RefreshDayGroup(
          date: date,
          records: grouped[date]!
            ..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
          summaryMessage: _daySummary(grouped[date]!),
        ),
    ];
  }

  static String _daySummary(List<RefreshHistoryRecord> records) {
    var odorFocus = 0;
    var dustFocus = 0;
    var bothFocus = 0;

    for (final record in records) {
      switch (record.careType) {
        case CareType.odor:
          odorFocus++;
        case CareType.dust:
          dustFocus++;
        case CareType.both:
          bothFocus++;
        case CareType.diagnosis:
          break;
      }
    }

    if (bothFocus >= odorFocus && bothFocus >= dustFocus && bothFocus > 0) {
      return '냄새와 먼지를 함께 케어한 날이에요.';
    }
    if (odorFocus >= dustFocus && odorFocus > 0) {
      return '냄새관리에 집중했던 날이에요.';
    }
    if (dustFocus > 0) {
      return '먼지관리에 집중했던 날이에요.';
    }
    return '가벼운 케어 위주로 사용했어요.';
  }

  static RefreshMonthlySummary _monthlySummary(
    List<RefreshHistoryRecord> records,
    DateTime month,
    Map<DateTime, RefreshMonthlySummary> computed,
  ) {
    final monthRecords = records
        .where((record) => _isSameMonth(record.dateTime, month))
        .toList();
    final previousMonth = RefreshHistoryReport.monthBefore(month);
    final previousSummary = computed[previousMonth];
    final previousCount =
        previousSummary?.totalCount ??
        records
            .where((record) => _isSameMonth(record.dateTime, previousMonth))
            .length;

    final improvements = monthRecords
        .map((record) => record.necessityReductionPercent)
        .whereType<double>()
        .toList();
    final avgImprovement = improvements.isEmpty
        ? 0.0
        : improvements.reduce((a, b) => a + b) / improvements.length;

    final previousImprovements = records
        .where((record) => _isSameMonth(record.dateTime, previousMonth))
        .map((record) => record.necessityReductionPercent)
        .whereType<double>()
        .toList();
    final previousAvg = previousImprovements.isEmpty
        ? avgImprovement
        : previousImprovements.reduce((a, b) => a + b) /
              previousImprovements.length;

    return RefreshMonthlySummary(
      month: month,
      totalCount: monthRecords.length,
      vsLastMonthDelta: monthRecords.length - previousCount,
      improvementPercent: avgImprovement,
      improvementDeltaPercent: avgImprovement - previousAvg,
      mostUsedMode: _mostUsedMode(monthRecords),
      mostUsedTimeRange: _mostUsedTimeRange(monthRecords),
    );
  }

  static RefreshTotalSummary _buildTotalSummary(
    List<RefreshHistoryRecord> records,
    String userName,
  ) {
    final totalCount = records.length;
    final improvements = records
        .map((record) => record.necessityReductionPercent)
        .whereType<double>()
        .toList();
    final averageImprovement = improvements.isEmpty
        ? 0.0
        : improvements.reduce((a, b) => a + b) / improvements.length;

    final odorHighCount = records.where(_isOdorHighBefore).length;
    final dustHighCount = records.where(_isDustHighBefore).length;
    final highTotal = odorHighCount + dustHighCount;
    final odorHighPercent = highTotal == 0
        ? 0.0
        : (odorHighCount / highTotal) * 100;
    final dustHighPercent = highTotal == 0
        ? 0.0
        : (dustHighCount / highTotal) * 100;

    final timeCounts = _timeUsageCounts(records);
    final sortedTime = timeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTime = sortedTime.isEmpty ? null : sortedTime.first;

    final careCounts = _careTypeCounts(records);
    final careTotal = careCounts.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    final odorCarePercent = careTotal == 0
        ? 0.0
        : (careCounts[CareType.odor]! + careCounts[CareType.both]!) /
              careTotal *
              100;
    final dustCarePercent = careTotal == 0 ? 0.0 : 100 - odorCarePercent;

    final modeUsages = _modeUsages(records);
    final topMode = modeUsages.isEmpty ? null : modeUsages.first;

    return RefreshTotalSummary(
      introMessage:
          '리프레시가 점점 ${userName.isEmpty ? '고객' : userName}님의\n'
          '외출 후 루틴으로 자리 잡고 있어요.',
      totalCount: totalCount,
      averageImprovementPercent: averageImprovement,
      preStatePattern: HistoryInsight(
        title: '리프레시 전 상태 패턴',
        descriptions: [
          if (odorHighCount > 0) '리프레시 전에는 냄새 높음 상태가 자주 감지됐어요',
          if (dustHighCount > 0) '냄새와 먼지 흔적이 함께 감지된 날이 많았어요.',
          if (odorHighCount == 0 && dustHighCount == 0) '아직 충분한 기록이 쌓이지 않았어요.',
        ],
        bars: [
          if (odorHighCount > 0)
            HistoryBarStat(
              label: '냄새 높음',
              percent: odorHighPercent,
              color: AppColors.orange600,
            ),
          if (dustHighCount > 0)
            HistoryBarStat(
              label: '먼지 높음',
              percent: dustHighPercent,
              color: AppColors.primary300,
            ),
        ],
      ),
      timeUsage: _timeRangeUsages(timeCounts),
      timeUsageInsight: HistoryInsight(
        title: '자주 사용한 시간대',
        descriptions: [
          if (topTime != null) '${topTime.key}에 리프레시를 자주 했어요',
          '하루 동안 쌓인 외부 흔적을 덜어내는 루틴으로 사용했어요.',
        ],
      ),
      careRatio: HistoryInsight(
        title: '주요 케어 비중',
        descriptions: [
          odorCarePercent >= dustCarePercent
              ? '냄새 중심의 케어를 가장 많이 사용했어요'
              : '먼지 중심의 케어를 가장 많이 사용했어요',
        ],
        bars: [
          HistoryBarStat(
            label: '냄새 케어',
            percent: odorCarePercent,
            color: AppColors.primary500,
          ),
          HistoryBarStat(
            label: '먼지 케어',
            percent: dustCarePercent,
            color: AppColors.blue700,
          ),
        ],
      ),
      modeUsageDescription: topMode == null
          ? '아직 사용한 모드가 없어요'
          : '${topMode.modeName}을 가장 많이 사용했어요',
      modeUsages: modeUsages,
    );
  }

  static bool _isOdorHighBefore(RefreshHistoryRecord record) {
    final status = record.odorBeforeStatus;
    return status == CareStatus.focusedRecommend ||
        status == CareStatus.focusedRequired;
  }

  static bool _isDustHighBefore(RefreshHistoryRecord record) {
    final status = record.dustBeforeStatus;
    return status == CareStatus.focusedRecommend ||
        status == CareStatus.focusedRequired;
  }

  static Map<CareType, int> _careTypeCounts(
    List<RefreshHistoryRecord> records,
  ) {
    final counts = {for (final type in CareType.values) type: 0};
    for (final record in records) {
      counts[record.careType] = counts[record.careType]! + 1;
    }
    return counts;
  }

  static Map<String, int> _timeUsageCounts(List<RefreshHistoryRecord> records) {
    final counts = <String, int>{};
    for (final record in records) {
      final bucket = _bucketForHour(record.dateTime.hour);
      if (bucket == null) {
        continue;
      }
      counts[bucket.label] = (counts[bucket.label] ?? 0) + 1;
    }
    return counts;
  }

  static List<TimeRangeUsage> _timeRangeUsages(Map<String, int> counts) {
    if (counts.isEmpty) {
      return const [];
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      AppColors.primary500,
      AppColors.primary400,
      AppColors.primary300,
    ];

    return [
      for (var i = 0; i < sorted.length && i < 3; i++)
        TimeRangeUsage(
          count: sorted[i].value,
          label: sorted[i].key,
          color: colors[i],
          startHour: _bucketForLabel(sorted[i].key)?.startHour ?? 0,
          endHour: _bucketForLabel(sorted[i].key)?.endHour ?? 24,
        ),
    ];
  }

  static List<ModeUsage> _modeUsages(List<RefreshHistoryRecord> records) {
    final grouped = <String, List<RefreshHistoryRecord>>{};
    for (final record in records) {
      grouped.putIfAbsent(record.modeName, () => []).add(record);
    }

    final usages = grouped.entries.map((entry) {
      final improvements = entry.value
          .map((record) => record.necessityReductionPercent)
          .whereType<double>()
          .toList();
      final avg = improvements.isEmpty
          ? 0.0
          : improvements.reduce((a, b) => a + b) / improvements.length;
      return ModeUsage(
        count: entry.value.length,
        modeName: entry.key,
        improvementPercent: avg,
      );
    }).toList()..sort((a, b) => b.count.compareTo(a.count));

    return usages;
  }

  static String _mostUsedMode(List<RefreshHistoryRecord> records) {
    if (records.isEmpty) {
      return '-';
    }
    final counts = <String, int>{};
    for (final record in records) {
      counts[record.modeName] = (counts[record.modeName] ?? 0) + 1;
    }
    return _topEntry(counts)?.key ?? '-';
  }

  static String _mostUsedTimeRange(List<RefreshHistoryRecord> records) {
    final counts = _timeUsageCounts(records);
    return _topEntry(counts)?.key ?? '-';
  }

  static MapEntry<String, int>? _topEntry(Map<String, int> counts) {
    if (counts.isEmpty) {
      return null;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  }

  static String _topWeekdayLabels(List<int> weekdayCounts) {
    final entries = <MapEntry<int, int>>[];
    for (var i = 0; i < weekdayCounts.length; i++) {
      if (weekdayCounts[i] > 0) {
        entries.add(MapEntry(i, weekdayCounts[i]));
      }
    }
    if (entries.isEmpty) {
      return '';
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    const labels = ['월', '화', '수', '목', '금', '토', '일'];
    return entries.take(2).map((entry) => '${labels[entry.key]}요일').join('·');
  }

  static _TimeBucket? _bucketForHour(int hour) {
    for (final bucket in _timeBuckets) {
      if (hour >= bucket.startHour && hour < bucket.endHour) {
        return bucket;
      }
    }
    return null;
  }

  static _TimeBucket? _bucketForLabel(String label) {
    for (final bucket in _timeBuckets) {
      if (bucket.label == label) {
        return bucket;
      }
    }
    return null;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime _monthKey(DateTime value) =>
      DateTime(value.year, value.month);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isSameMonth(DateTime value, DateTime month) =>
      value.year == month.year && value.month == month.month;
}

class _TimeBucket {
  const _TimeBucket({
    required this.startHour,
    required this.endHour,
    required this.label,
  });

  final int startHour;
  final int endHour;
  final String label;
}
