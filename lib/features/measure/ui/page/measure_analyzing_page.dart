import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/measure_api.dart';
import '../../data/api/measure_refresh_recommend_service.dart';
import '../../data/measure_result_store.dart';
import '../../data/model/measure_result.dart';
import '../widgets/measure_analyzing_illustration.dart';
import '../widgets/measure_prepare_instruction.dart';

/// 진단 완료 후 결과를 분석하는 중간 화면.
///
/// 잠시 로딩 후 [MeasureResultPage]로 자동 전환됩니다.
class MeasureAnalyzingPage extends StatefulWidget {
  const MeasureAnalyzingPage({super.key});

  @override
  State<MeasureAnalyzingPage> createState() => _MeasureAnalyzingPageState();
}

class _MeasureAnalyzingPageState extends State<MeasureAnalyzingPage> {
  static const Duration _analyzingDuration = Duration(seconds: 3);

  final _recommendService = const MeasureRefreshRecommendService();

  Timer? _timer;
  bool _navigated = false;
  Future<MeasureResult>? _recommendFuture;

  @override
  void initState() {
    super.initState();
    _recommendFuture = _recommendService.runDiagnosis();
    _timer = Timer(_analyzingDuration, _goToResult);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goToResult() async {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;

    try {
      final result =
          await (_recommendFuture ?? _recommendService.runDiagnosis());
      MeasureResultStore.instance.setPending(result);
    } on MeasureApiException catch (error) {
      MeasureResultStore.instance.setLoadError(error.message);
      debugPrint('MeasureAnalyzingPage recommend failed: $error');
    } catch (error, stackTrace) {
      MeasureResultStore.instance.setLoadError('진단 결과 저장에 실패했습니다.');
      debugPrint('MeasureAnalyzingPage recommend failed: $error\n$stackTrace');
    }

    if (!mounted) {
      return;
    }

    context.pushReplacementNamed(AppRouteNames.measureResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '헤어 상태 진단',
        onBack: () => context.pop(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const SizedBox(height: 128),
            const MeasureAnalyzingIllustration(),
            const SizedBox(height: AppSpacing.lg),
            const MeasurePrepareInstruction(
              title: '결과를 분석 중이에요',
              subtitle: '냄새, 먼지, 모발 상태를 종합해\n맞춤 리프레시를 준비하고 있어요.',
            ),
          ],
        ),
      ),
    );
  }
}
