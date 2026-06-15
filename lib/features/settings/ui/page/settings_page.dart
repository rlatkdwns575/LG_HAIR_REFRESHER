import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_top_header.dart';
import '../../../auth/data/api/auth_api.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authApi = const AuthApi();

  bool _isSigningOut = false;

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
            content: Text(error.message),
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
      appBar: AppTopHeader(
        title: '설정 / 연동',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray800),
          onPressed: () => context.go(AppRoutePaths.home),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(15, AppSpacing.lg, 15, 20),
          children: [
            Text(
              '디바이스, 캘린더, 외부 환경 데이터, 알림을 관리합니다.',
              style: AppTextStyles.bodyS.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: AppSpacing.lg),
            const _SettingsSection(
              items: [
                '디바이스 연동',
                'Google Calendar 연동',
                '외부 환경 데이터 연동',
                '알림 및 소모품 관리',
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.gray100),
            ListTile(
              title: Text(
                items[i],
                style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray800),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.gray400,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            ),
          ],
        ],
      ),
    );
  }
}
