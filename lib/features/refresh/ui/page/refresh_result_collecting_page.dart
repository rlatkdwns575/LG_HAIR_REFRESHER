import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../widgets/refresh_result_collecting_illustration.dart';

/// 리프레시 진행 완료 후 최종 결과 화면 전 잠시 보여주는 수집 중 화면.
///
/// 잠시 로딩 후 [RefreshResultPage]로 자동 전환됩니다.
class RefreshResultCollectingPage extends StatefulWidget {
  const RefreshResultCollectingPage({super.key});

  @override
  State<RefreshResultCollectingPage> createState() =>
      _RefreshResultCollectingPageState();
}

class _RefreshResultCollectingPageState
    extends State<RefreshResultCollectingPage> {
  static const Duration _collectingDuration = Duration(milliseconds: 2500);

  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_collectingDuration, _goToResult);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToResult() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    context.pushReplacementNamed(AppRouteNames.refreshResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시하기',
        onBack: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 160),
            const RefreshResultCollectingIllustration(),
            const SizedBox(height: 40),
            Text(
              '리프레시 결과를 수집중이에요',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleL.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '케어 결과를 정리한 뒤 최종 결과를 보여드릴게요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray500),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
