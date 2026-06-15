import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/refresh_api.dart';
import '../../data/model/refresh_result.dart';
import '../../data/refresh_mode_catalog.dart';
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

  Future<void> _onRecommendTap() async {
    var mode = _result.recommendedMode ?? resolveScentCareMode();
    mode ??= await const RefreshApi().fetchScentCarePreset();
    if (mode == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('향기 케어 모드를 불러오지 못했어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (!mounted) {
      return;
    }

    context.pushRefreshProgress(mode: mode);
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
          title: '헤어 리프레시',
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
