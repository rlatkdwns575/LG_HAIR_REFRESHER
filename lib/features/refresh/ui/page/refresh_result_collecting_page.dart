import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/recommendation/refresh_recommend_service.dart';
import '../../../measure/data/api/measure_api.dart';
import '../../../measure/data/model/measure_result_record.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/refresh_session_api.dart';
import '../../data/api/refresh_session_result_generator.dart';
import '../../data/refresh_result_store.dart';
import '../widgets/refresh_result_collecting_illustration.dart';

/// 리프레시 진행 완료 후 최종 결과 화면 전 잠시 보여주는 수집 중 화면.
///
/// 결과 생성·DB 저장 후 [RefreshResultPage]로 자동 전환됩니다.
class RefreshResultCollectingPage extends StatefulWidget {
  const RefreshResultCollectingPage({super.key});

  @override
  State<RefreshResultCollectingPage> createState() =>
      _RefreshResultCollectingPageState();
}

class _RefreshResultCollectingPageState
    extends State<RefreshResultCollectingPage> {
  static const Duration _collectingDuration = Duration(milliseconds: 2500);

  final _measureApi = const MeasureApi();
  final _refreshSessionApi = const RefreshSessionApi();
  final _resultGenerator = const RefreshSessionResultGenerator();

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _prepareAndPersist();
  }

  Future<void> _prepareAndPersist() async {
    final startedAt = DateTime.now();
    final mode = RefreshResultStore.instance.peekPendingMode();
    if (mode == null) {
      await _waitRemaining(startedAt);
      _goToResult();
      return;
    }

    MeasureResultRecord? baseline;
    try {
      baseline = await _measureApi.fetchLatestResult();
    } catch (error, stackTrace) {
      debugPrint(
        'RefreshResultCollectingPage baseline fetch failed: '
        '$error\n$stackTrace',
      );
    }

    try {
      final outcome = _resultGenerator.generate(mode: mode, baseline: baseline);

      RefreshResultStore.instance.setPending(outcome.result, mode: mode);

      await _refreshSessionApi.saveCompletedSession(
        outcome: outcome,
        mode: mode,
      );
      RefreshRecommendService.invalidateCache();
    } on RefreshSessionApiException catch (error, stackTrace) {
      debugPrint(
        'RefreshResultCollectingPage persist session failed: '
        '$error\n$stackTrace',
      );
      if (RefreshResultStore.instance.peekPendingResult() == null) {
        final outcome = _resultGenerator.generate(
          mode: mode,
          baseline: baseline,
        );
        RefreshResultStore.instance.setPending(outcome.result, mode: mode);
      }
    } catch (error, stackTrace) {
      debugPrint(
        'RefreshResultCollectingPage persist session failed: '
        '$error\n$stackTrace',
      );

      if (RefreshResultStore.instance.peekPendingResult() == null) {
        final outcome = _resultGenerator.generate(
          mode: mode,
          baseline: baseline,
        );
        RefreshResultStore.instance.setPending(outcome.result, mode: mode);
      }
    }

    await _waitRemaining(startedAt);
    _goToResult();
  }

  Future<void> _waitRemaining(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _collectingDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
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
            AppText(
              '리프레시 결과를 수집중이에요',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleL.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
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
