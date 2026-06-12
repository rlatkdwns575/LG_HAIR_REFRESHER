import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/history_api.dart';
import '../../data/model/refresh_history_record.dart';
import '../../data/model/refresh_history_report.dart';
import '../../data/refresh_history_store.dart';
import '../widgets/history_common.dart';
import '../widgets/history_month_picker.dart';
import '../widgets/history_recent_section.dart';
import '../widgets/history_today_section.dart';
import '../widgets/history_total_section.dart';

/// 나의 리프레시 기록 리포트 화면.
///
/// 오늘 요약 / 최근 기록(캘린더) / 전체 기록 인사이트 세 섹션으로 구성됩니다.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const _horizontalPadding = 15.0;
  static final _minMonth = DateTime(1970, 1);

  RefreshHistoryReport? _report;
  late DateTime _visibleMonth;
  DateTime? _selectedDate;
  bool _calendarExpanded = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final report = await RefreshHistoryStore.instance.loadReport();
      if (!mounted) {
        return;
      }
      setState(() {
        _report = report;
        _visibleMonth = report.defaultMonth;
        _selectedDate = report.monthDataFor(_visibleMonth).latestRecordedDate;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('History report load failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error is HistoryApiException
            ? error.message
            : '리프레시 기록을 불러오지 못했어요.';
      });
    }
  }

  RefreshHistoryMonthData get _visibleMonthData =>
      _report?.monthDataFor(_visibleMonth) ??
      RefreshHistoryMonthData.empty(_visibleMonth);

  bool get _canGoPreviousMonth {
    return _visibleMonth.year > _minMonth.year ||
        (_visibleMonth.year == _minMonth.year &&
            _visibleMonth.month > _minMonth.month);
  }

  bool get _canGoNextMonth {
    final report = _report;
    if (report == null) {
      return false;
    }
    final latest = report.defaultMonth;
    return _visibleMonth.year < latest.year ||
        (_visibleMonth.year == latest.year &&
            _visibleMonth.month < latest.month);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goHome();
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() => _selectedDate = date);
  }

  void _onToggleExpanded() {
    setState(() => _calendarExpanded = !_calendarExpanded);
  }

  void _onPreviousMonth() {
    if (!_canGoPreviousMonth) {
      return;
    }
    setState(() {
      _visibleMonth = RefreshHistoryReport.monthBefore(_visibleMonth);
      _selectedDate = _visibleMonthData.latestRecordedDate;
    });
  }

  void _onNextMonth() {
    if (!_canGoNextMonth) {
      return;
    }
    setState(() {
      _visibleMonth = RefreshHistoryReport.monthAfter(_visibleMonth);
      _selectedDate = _visibleMonthData.latestRecordedDate;
    });
  }

  Future<void> _onCalendarIconTap() async {
    final report = _report;
    if (report == null) {
      return;
    }

    final picked = await showHistoryMonthPicker(
      context: context,
      initialMonth: _visibleMonth,
      maxMonth: report.defaultMonth,
      minMonth: _minMonth,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _visibleMonth = DateTime(picked.year, picked.month);
      _selectedDate = _visibleMonthData.latestRecordedDate;
    });
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  void _onRecordDetailTap(RefreshHistoryRecord record) {
    _showComingSoon('${record.modeName} 상세 결과는 준비 중이에요.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 내역',
        onBack: _onBack,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    final report = _report!;
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        _buildTitleArea(report),
        _padded(
          HistoryTodaySection(
            report: report,
            onRecordDetailTap: _onRecordDetailTap,
            onRoutineRegisterTap: () => _showComingSoon('루틴 등록 기능은 준비 중이에요.'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const HistorySectionDivider(),
        const SizedBox(height: AppSpacing.lg),
        _padded(
          HistoryRecentSection(
            asOfDate: report.asOfDate,
            visibleMonth: _visibleMonth,
            monthData: _visibleMonthData,
            selectedDate: _selectedDate,
            calendarExpanded: _calendarExpanded,
            canGoPreviousMonth: _canGoPreviousMonth,
            canGoNextMonth: _canGoNextMonth,
            onPreviousMonth: _onPreviousMonth,
            onNextMonth: _onNextMonth,
            onCalendarIconTap: _onCalendarIconTap,
            onDateSelected: _onDateSelected,
            onToggleExpanded: _onToggleExpanded,
            onDayResultDetailTap: () =>
                _showComingSoon('선택한 날짜의 상세 결과는 준비 중이에요.'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const HistorySectionDivider(),
        const SizedBox(height: AppSpacing.lg),
        _padded(HistoryTotalSection(summary: report.totalSummary)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray700),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: _loadReport, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleArea(RefreshHistoryReport report) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _horizontalPadding,
        AppSpacing.sm,
        _horizontalPadding,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 리프레시 기록 리포트',
            style: AppTextStyles.titleL.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 6),
          Text(
            formatKoreanAsOf(report.asOfDate),
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _padded(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: child,
    );
  }
}
