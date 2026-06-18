import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/calendar_events_api.dart';
import '../../../../core/services/local_calendar_connect_result.dart';
import '../../../../core/services/local_calendar_service.dart';
import '../../../../shared/models/local_calendar_status.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../widgets/device_manage_status_panel.dart';
import '../widgets/settings_section_card.dart';

class LocalCalendarSettingsPage extends StatefulWidget {
  const LocalCalendarSettingsPage({super.key});

  @override
  State<LocalCalendarSettingsPage> createState() =>
      _LocalCalendarSettingsPageState();
}

class _LocalCalendarSettingsPageState extends State<LocalCalendarSettingsPage> {
  final _localCalendarService = LocalCalendarService();

  LocalCalendarStatus _status = LocalCalendarStatus.disconnected;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _localCalendarService.fetchStatus();
    if (!mounted) {
      return;
    }

    if (status.permissionGranted) {
      try {
        final refreshed = await _localCalendarService.refreshConnection();
        if (!mounted) {
          return;
        }
        setState(() => _status = refreshed);
        return;
      } on CalendarEventsApiException catch (error) {
        if (!mounted) {
          return;
        }
        final fallbackStatus = await _localCalendarService.fetchStatus();
        if (!mounted) {
          return;
        }
        setState(() => _status = fallbackStatus);
        if (_status.todayEventCount > 0) {
          return;
        }
        _showMessage(error.message);
        return;
      }
    }

    setState(() => _status = status);
  }

  Future<void> _requestAccess() async {
    setState(() => _isRefreshing = true);
    try {
      final result = await _localCalendarService.connect();
      if (!mounted) {
        return;
      }
      final resolvedStatus =
          result.status ?? await _localCalendarService.fetchStatus();
      if (!mounted) {
        return;
      }
      setState(() => _status = resolvedStatus);

      switch (result.outcome) {
        case LocalCalendarConnectOutcome.connected:
          _showMessage(_status.statusMessage);
        case LocalCalendarConnectOutcome.permissionDenied:
          _showMessage(
            result.errorMessage ?? '캘린더 접근 권한이 필요합니다. 기기 설정에서 허용해 주세요.',
          );
        case LocalCalendarConnectOutcome.syncFailed:
          _showMessage(
            result.errorMessage ?? '일정 동기화에 실패했습니다. 네트워크와 권한을 확인해 주세요.',
          );
        case LocalCalendarConnectOutcome.skipped:
        case LocalCalendarConnectOutcome.cancelled:
          _showMessage('이 기기에서는 로컬 캘린더 연동을 지원하지 않습니다.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('캘린더 연동에 실패했습니다. 잠시 후 다시 시도해 주세요.');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _refreshConnection() async {
    if (!_status.permissionGranted) {
      _showMessage('먼저 캘린더 접근을 허용해 주세요.');
      return;
    }

    setState(() => _isRefreshing = true);
    try {
      final status = await _localCalendarService.refreshConnection();
      if (!mounted) {
        return;
      }
      setState(() => _status = status);
      _showMessage(_status.statusMessage);
    } on CalendarEventsApiException catch (error) {
      if (!mounted) {
        return;
      }
      final status = await _localCalendarService.fetchStatus();
      setState(() => _status = status);
      if (status.todayEventCount > 0) {
        _showMessage(
          '기기에서 ${status.todayEventCount}건을 확인했습니다. 서버 저장 오류: ${error.message}',
        );
      } else {
        _showMessage(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('일정 동기화에 실패했습니다. 네트워크와 권한을 확인해 주세요.');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  Future<void> _disconnect() async {
    setState(() => _isRefreshing = true);
    try {
      final status = await _localCalendarService.disconnect();
      if (!mounted) {
        return;
      }
      setState(() => _status = status);
      _showMessage('로컬 캘린더 연동을 해제했습니다.');
    } on CalendarEventsApiException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('연동 해제 중 오류가 발생했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: AppText(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '로컬 캘린더',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshConnection,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: AppSystemInsets.pageHorizontal(
            context,
            top: AppSpacing.lg,
            extraBottom: 24,
          ),
          children: [
            _ConnectionHero(status: _status),
            const SizedBox(height: AppSpacing.lg),
            SettingsSectionCard(
              title: '연동 상태',
              children: [
                DeviceManageInfoRow(
                  label: '연결',
                  value: _status.connectionLabel,
                ),
                const SettingsDivider(),
                DeviceManageInfoRow(
                  label: '캘린더 권한',
                  value: _status.permissionLabel,
                ),
                const SettingsDivider(),
                DeviceManageInfoRow(
                  label: '마지막 확인',
                  value: _status.lastCheckedLabel,
                ),
                const SettingsDivider(),
                DeviceManageInfoRow(
                  label: '기기 읽기',
                  value: _status.deviceFetchLabel,
                ),
                const SettingsDivider(),
                DeviceManageInfoRow(
                  label: '오늘 일정',
                  value: _status.isConnected
                      ? '${_status.todayEventCount}건'
                      : '—',
                ),
                const SettingsDivider(),
                DeviceManageInfoRow(
                  label: '다음 일정',
                  value: _status.nextEventLabel,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSectionCard(
              title: '안내',
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                  child: AppText(
                    _status.statusMessage,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            if (!_status.permissionGranted)
              AppBoxButton(
                label: _isRefreshing ? '연동 확인 중...' : '캘린더 접근 허용',
                variant: AppBoxButtonVariant.active,
                onPressed: _isRefreshing ? null : _requestAccess,
              )
            else ...[
              AppBoxButton(
                label: _isRefreshing ? '확인 중...' : '연동 상태 확인',
                variant: AppBoxButtonVariant.active,
                onPressed: _isRefreshing ? null : _refreshConnection,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppBoxButton(
                label: '연동 해제',
                variant: AppBoxButtonVariant.line,
                onPressed: _status.isConnected && !_isRefreshing
                    ? _disconnect
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConnectionHero extends StatelessWidget {
  const _ConnectionHero({required this.status});

  final LocalCalendarStatus status;

  @override
  Widget build(BuildContext context) {
    final isConnected = status.isConnected;
    final color = isConnected ? AppColors.safe500 : AppColors.gray400;
    final label = isConnected ? '연동됨' : '연동 안 됨';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 72,
            color: isConnected ? AppColors.primary500 : AppColors.gray300,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            '기기 로컬 캘린더',
            style: AppTextStyles.titleM.copyWith(color: AppColors.gray900),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isConnected ? AppColors.green100 : AppColors.gray50,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                AppText(
                  label,
                  style: AppTextStyles.labelS.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            '일정 기반 리프레시·측정 추천에 사용됩니다.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}
