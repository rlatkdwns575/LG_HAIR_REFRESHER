import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/model/refresh_result.dart';
import '../../data/refresh_result_store.dart';
import '../widgets/refresh_result_content.dart';

/// Figma 622-13066 — 리프레시 완료 후 최종 결과 화면.
class RefreshResultPage extends StatefulWidget {
  const RefreshResultPage({super.key});

  @override
  State<RefreshResultPage> createState() => _RefreshResultPageState();
}

class _RefreshResultPageState extends State<RefreshResultPage> {
  late final RefreshResult _result;

  @override
  void initState() {
    super.initState();
    _result = RefreshResultStore.instance.consume();
  }

  void _goHome() => context.goHome();

  void _onDetailTap() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('상세 결과 화면은 준비 중이에요.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _onRecommendTap() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${_result.recommendedMode.name} 모드를 선택했어요'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _goHome();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppCommonTopHeader(
          variant: AppCommonTopHeaderVariant.gnb,
          title: '리프레시',
          onBack: _goHome,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            15,
            AppSpacing.xl,
            15,
            AppSpacing.xl,
          ),
          children: [
            RefreshResultContent(
              result: _result,
              onDetailTap: _onDetailTap,
              onRecommendTap: _onRecommendTap,
            ),
          ],
        ),
      ),
    );
  }
}
