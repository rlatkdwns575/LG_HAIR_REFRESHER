import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
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
  final _localCalendarService = const LocalCalendarService();

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
    setState(() => _status = status);
  }

  Future<void> _requestAccess() async {
    setState(() => _isRefreshing = true);
    final status = await _localCalendarService.requestAccess();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _isRefreshing = false;
    });
    _showMessage('로컬 캘린더 연동을 확인했습니다.');
  }

  Future<void> _refreshConnection() async {
    if (!_status.permissionGranted) {
      _showMessage('먼저 캘린더 접근을 허용해 주세요.');
      return;
    }

    setState(() => _isRefreshing = true);
    final status = await _localCalendarService.refreshConnection();
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _isRefreshing = false;
    });
    _showMessage(_status.statusMessage);
  }

  Future<void> _disconnect() async {
    final status = await _localCalendarService.disconnect();
    if (!mounted) {
      return;
    }
    setState(() => _status = status);
    _showMessage('로컬 캘린더 연동을 해제했습니다.');
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
