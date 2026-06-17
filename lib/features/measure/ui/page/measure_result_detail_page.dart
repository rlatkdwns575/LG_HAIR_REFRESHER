import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../refresh/data/refresh_mode_availability.dart';
import '../../../refresh/ui/refresh_scent_unavailable.dart';
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
  final _recommendService = MeasureRefreshRecommendService();
  final _deviceConsumableService = const DeviceConsumableService();

  MeasureResult? _result;
  MeasureResultDetail? _detail;
  bool _isLoading = true;
  bool _isScentCartridgeAttached = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadScentCartridgeStatus();
    _resolveResult();
  }

  Future<void> _loadScentCartridgeStatus() async {
    final cartridge = await _deviceConsumableService
        .fetchScentCartridgeStatus();
    if (!mounted) {
      return;
    }
    setState(() => _isScentCartridgeAttached = cartridge.isAttached);
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
    } catch (_) {
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
    Clipboard.setData(ClipboardData(text: detail.shareSummaryText));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: AppText('진단 결과 요약이 복사되었습니다.'),
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
                child: AppText(
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
                    padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, 0),
                    children: [
                      MeasureResultDetailContent(
                        detail: detail,
                        isRecommendEnabled: RefreshModeAvailability.isEnabled(
                          result.recommendedMode,
                          ScentCartridgeStatus(
                            isAttached: _isScentCartridgeAttached,
                          ),
                        ),
                        onRecommendTap: () {
                          if (!RefreshModeAvailability.isEnabled(
                            result.recommendedMode,
                            ScentCartridgeStatus(
                              isAttached: _isScentCartridgeAttached,
                            ),
                          )) {
                            showRefreshScentUnavailableSnackBar(context);
                            return;
                          }
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
