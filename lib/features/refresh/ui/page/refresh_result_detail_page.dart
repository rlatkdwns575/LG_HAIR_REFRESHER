import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/image_assets.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/model/refresh_result_detail.dart';
import '../widgets/refresh_result_detail_content.dart';

/// Figma 1170-16711 / 1182-20490 — 리프레시 결과 상세보기.
class RefreshResultDetailPage extends StatelessWidget {
  const RefreshResultDetailPage({required this.detail, super.key});

  final RefreshResultDetail detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 결과보기',
        onBack: () => context.pop(),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: AppText('공유 기능은 준비 중이에요.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            icon: Image.asset(
              ImageAssets.refreshShareIcon,
              width: 20,
              height: 20,
            ),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSystemInsets.onlyBottom(
            context,
            extra: AppSpacing.xl,
          ).bottom,
        ),
        children: [RefreshResultDetailContent(detail: detail)],
      ),
    );
  }
}

/// route extra 가 없을 때 표시하는 fallback.
class RefreshResultDetailPageFallback extends StatelessWidget {
  const RefreshResultDetailPageFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshResultDetailPage(detail: RefreshResultDetail.sample);
  }
}
