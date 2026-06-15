import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/api/measure_api.dart';
import '../../data/api/measure_refresh_recommend_service.dart';
import '../../data/model/measure_result.dart';
import '../../data/model/measure_result_detail.dart';
import '../widgets/measure_result_detail_content.dart';

class MeasureResultDetailPage extends StatefulWidget {
  const MeasureResultDetailPage({required this.result, super.key});

  final MeasureResult result;

  @override
  State<MeasureResultDetailPage> createState() =>
      _MeasureResultDetailPageState();
}

class _MeasureResultDetailPageState extends State<MeasureResultDetailPage> {
  final _recommendService = const MeasureRefreshRecommendService();

  MeasureResult? _result;
  MeasureResultDetail? _detail;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _resolveResult();
  }

  Future<void> _resolveResult() async {
    try {
      MeasureResult resolved = widget.result;
      if (resolved.sourceRecord == null) {
        resolved = await _recommendService.buildMeasureResult();
      }
      final detail = MeasureResultDetail.fromMeasureResult(resolved);
      if (!mounted) {
        return;
      }
      setState(() {
        _result = resolved;
        _detail = detail;
        _isLoading = false;
      });
    } on MeasureApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('MeasureResultDetailPage load failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = '진단 상세 결과를 불러오지 못했습니다.';
        _isLoading = false;
      });
    }
  }

  void _onShare(MeasureResultDetail detail) {
    final text = [
      '내 헤어 상태 진단 결과',
      '리프레시 필요도 ${detail.refreshNeedPercent}%',
      detail.analysisSummary.replaceAll('\n', ' '),
    ].join('\n');

    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('진단 결과 요약이 복사되었어요.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final detail = _detail;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '내 헤어 상태 보기',
        onBack: () => Navigator.of(context).pop(),
        onShare: detail == null ? null : () => _onShare(detail),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : result == null || detail == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  _loadError ?? '진단 상세 결과가 없습니다.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.gray500),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      AppSpacing.sm,
                      15,
                      0,
                    ),
                    children: [
                      MeasureResultDetailContent(
                        detail: detail,
                        onRecommendTap: () {
                          context.pushRefreshDetail(
                            mode: result.recommendedMode,
                          );
                        },
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
                      onPressed: () => context.pushMeasure(),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
