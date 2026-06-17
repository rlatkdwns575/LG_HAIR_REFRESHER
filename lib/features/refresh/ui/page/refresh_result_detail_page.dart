import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/model/refresh_result_detail.dart';
import '../widgets/refresh_result_detail_content.dart';

/// Figma 1170-16711 / 1182-20490 — 리프레시 결과 상세보기.
class RefreshResultDetailPage extends StatelessWidget {
  const RefreshResultDetailPage({required this.detail, super.key});

  final RefreshResultDetail detail;

  void _onShare(BuildContext context) {
    Clipboard.setData(ClipboardData(text: detail.shareSummaryText));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: AppText('리프레시 결과 요약이 복사되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 결과보기',
        onBack: () => context.pop(),
        onShare: () => _onShare(context),
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
