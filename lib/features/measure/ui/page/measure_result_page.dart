import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/model/measure_result.dart';
import '../widgets/measure_result_content.dart';

class MeasureResultPage extends StatefulWidget {
  const MeasureResultPage({super.key});

  @override
  State<MeasureResultPage> createState() => _MeasureResultPageState();
}

class _MeasureResultPageState extends State<MeasureResultPage> {
  /// mock 전환: [MeasureResult.sampleStable] 로 바꾸면 안정형 화면 확인.
  static const MeasureResult _result = MeasureResult.sample;

  void _goHome() => context.goHome();

  void _onRediagnose() => context.pushMeasure();

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
          title: '현재 헤어 상태',
          onBack: _goHome,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(15, AppSpacing.sm, 15, 0),
                children: [
                  MeasureResultContent(
                    result: _result,
                    onDetailTap: _onDetailTap,
                    onRecommendTap: _onRecommendTap,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, AppSpacing.lg, 15, 20),
                child: AppBoxButton(
                  label: '재진단 하기',
                  variant: AppBoxButtonVariant.line,
                  onPressed: _onRediagnose,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
