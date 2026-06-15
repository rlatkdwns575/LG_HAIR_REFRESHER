import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/measure_api.dart';
import '../../data/api/measure_refresh_recommend_service.dart';
import '../../data/measure_result_store.dart';
import '../../data/model/measure_result.dart';
import '../widgets/measure_result_content.dart';

class MeasureResultPage extends StatefulWidget {
  const MeasureResultPage({super.key});

  @override
  State<MeasureResultPage> createState() => _MeasureResultPageState();
}

class _MeasureResultPageState extends State<MeasureResultPage> {
  final _recommendService = const MeasureRefreshRecommendService();

  MeasureResult? _result;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _resolveResult();
  }

  Future<void> _resolveResult() async {
    final storeError = MeasureResultStore.instance.consumeLoadError();
    if (storeError != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = storeError;
        _isLoading = false;
      });
      return;
    }

    final pending = MeasureResultStore.instance.consume();
    if (pending != null && pending.sourceRecord != null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _result = pending;
        _isLoading = false;
      });
      return;
    }

    try {
      final result = await _recommendService.buildMeasureResult();
      if (!mounted) {
        return;
      }
      setState(() {
        _result = result;
        _isLoading = false;
      });
    } on MeasureApiException catch (error) {
      debugPrint('MeasureResultPage load failed: $error');
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('MeasureResultPage load failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = '진단 결과를 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  void _goHome() => context.goHome();

  void _onRediagnose() => context.pushMeasure();

  void _onDetailTap() {
    final result = _result;
    if (result == null || result.sourceRecord == null) {
      return;
    }
    context.pushMeasureResultDetail(result: result);
  }

  void _onRecommendTap() {
    final result = _result;
    if (result == null) {
      return;
    }
    context.pushRefreshDetail(mode: result.recommendedMode);
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;

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
          title: '헤어 상태 진단',
          onBack: _goHome,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : result == null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _loadError ?? '진단 결과가 없습니다.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
                  ),
                ),
              )
            : Column(
                children: [
                  if (_loadError != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        AppSpacing.sm,
                        15,
                        0,
                      ),
                      child: Text(
                        _loadError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        AppSpacing.sm,
                        15,
                        0,
                      ),
                      children: [
                        MeasureResultContent(
                          result: result,
                          onDetailTap: _onDetailTap,
                          onRecommendTap: _onRecommendTap,
                        ),
                      ],
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        15,
                        AppSpacing.lg,
                        15,
                        20,
                      ),
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
