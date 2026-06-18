import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../../../../core/services/local_calendar_service.dart';
import '../../../../shared/models/local_calendar_status.dart';
import '../../../auth/data/api/auth_api.dart';
import '../../data/api/settings_api.dart';
import '../../data/model/settings_device_detail.dart';
import '../../data/model/settings_user_summary.dart';
import '../widgets/settings_profile_card.dart';
import '../widgets/settings_section_card.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authApi = const AuthApi();
  final _settingsApi = const SettingsApi();
  final _localCalendarService = LocalCalendarService();

  SettingsUserSummary _user = SettingsUserSummary.guest;
  SettingsDeviceDetail _device = SettingsDeviceDetail.fallback;
  LocalCalendarStatus _localCalendarStatus = LocalCalendarStatus.disconnected;
  bool _isLoading = true;
  bool _isSigningOut = false;

  bool _refreshReminderEnabled = true;
  bool _consumableAlertEnabled = true;
  bool _recommendPushEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _settingsApi.fetchUserSummary(),
      _settingsApi.fetchLinkedDevice(),
      _localCalendarService.fetchStatus(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _user = results[0] as SettingsUserSummary;
      _device = results[1] as SettingsDeviceDetail;
      _localCalendarStatus = results[2] as LocalCalendarStatus;
      _isLoading = false;
    });
  }

  Future<void> _openLocalCalendarSettings() async {
    await context.pushLocalCalendarSettings();
    if (!mounted) {
      return;
    }
    final status = await _localCalendarService.fetchStatus();
    setState(() => _localCalendarStatus = status);
  }

  Future<void> _handleSignOut() async {
    if (_isSigningOut) {
      return;
    }

    setState(() => _isSigningOut = true);

    try {
      await _authApi.signOut();
      if (!mounted) {
        return;
      }
      context.go(AppRoutePaths.login);
    } on AuthApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: AppText(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '설정 / 연동',
        onBack: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          } else {
            context.go(AppRoutePaths.home);
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSettings,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppSystemInsets.pageHorizontal(
                  context,
                  top: AppSpacing.lg,
                  extraBottom: 24,
                ),
                children: [
                  AppText(
                    '디바이스, 로컬 캘린더, 알림을 관리합니다.',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsProfileCard(user: _user),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSectionCard(
                    title: '디바이스',
                    children: [
                      SettingsListTile(
                        title: '디바이스 관리',
                        caption: _device.isConnected
                            ? '${_device.modelName} · 배터리 ${_device.batteryPercent}%'
                            : '연결된 기기 없음',
                        leadingIcon: Icons.devices_outlined,
                        onTap: context.pushDeviceManage,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSectionCard(
                    title: '연동',
                    children: [
                      SettingsListTile(
                        title: '로컬 캘린더',
                        caption: '기기 일정 기반 리프레시·측정 추천',
                        rightLabel: _localCalendarStatus.listRightLabel,
                        leadingIcon: Icons.calendar_month_outlined,
                        onTap: _openLocalCalendarSettings,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SettingsSectionCard(
                    title: '알림',
                    children: [
                      SettingsListTile(
                        title: '리프레시 알림',
                        caption: '측정 결과 기반 리마인더',
                        variant: AppListItemVariant.toggle,
                        toggleValue: _refreshReminderEnabled,
                        onChanged: (value) {
                          setState(() => _refreshReminderEnabled = value);
                        },
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        title: '소모품 교체 알림',
                        caption: '필터·배터리 상태 알림',
                        variant: AppListItemVariant.toggle,
                        toggleValue: _consumableAlertEnabled,
                        onChanged: (value) {
                          setState(() => _consumableAlertEnabled = value);
                        },
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        title: '맞춤 추천 푸시',
                        caption: '일정 기반 리프레시 추천',
                        variant: AppListItemVariant.toggle,
                        toggleValue: _recommendPushEnabled,
                        onChanged: (value) {
                          setState(() => _recommendPushEnabled = value);
                        },
                      ),
                      const SettingsDivider(),
                      SettingsListTile(
                        title: '추천 알림 관리',
                        caption: '리프레시 추천 알림을 추가·관리해요',
                        leadingIcon: Icons.notifications_active_outlined,
                        onTap: context.pushRoutineList,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppBoxButton(
                    label: _isSigningOut ? '로그아웃 중...' : '로그아웃',
                    variant: AppBoxButtonVariant.line,
                    onPressed: _isSigningOut ? null : _handleSignOut,
                  ),
                ],
              ),
            ),
    );
  }
}
