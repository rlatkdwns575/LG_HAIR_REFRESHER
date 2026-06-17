import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/model/refresh_mode_detail.dart';
import '../../data/refresh_mode_availability.dart';
import '../refresh_scent_unavailable.dart';
import '../widgets/refresh_detail_timeline.dart';

/// Figma Design `리프레시 상세` (833:14941 · 823:26534 · 833:15046).
class RefreshDetailPage extends StatefulWidget {
  const RefreshDetailPage({required this.mode, super.key});

  final RefreshMode mode;

  static const double _horizontalPadding = 28;
  static const double _preCheckMaxWidth = 320;

  /// Figma 833:14941 (360×800) — 섹션 간 세로 간격.
  static const double _gapAppBarToHeader = 56;
  static const double _gapHeaderTitleToTags = 18;
  static const double _gapHeaderToTimeline = 48;
  static const double _gapTimelineToPreCheck = 72;
  static const double _gapPreCheckToLink = 48;
  static const double _gapLinkToButton = 20;

  @override
  State<RefreshDetailPage> createState() => _RefreshDetailPageState();
}

class _RefreshDetailPageState extends State<RefreshDetailPage> {
  final _deviceConsumableService = const DeviceConsumableService();

  ScentCartridgeStatus _scentCartridge = ScentCartridgeStatus.notAttached;
  bool _isLoading = true;

  RefreshMode get mode => widget.mode;

  bool get _isModeEnabled =>
      RefreshModeAvailability.isEnabled(mode, _scentCartridge);

  @override
  void initState() {
    super.initState();
    _loadCartridgeStatus();
  }

  Future<void> _loadCartridgeStatus() async {
    final cartridge = await _deviceConsumableService
        .fetchScentCartridgeStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      _scentCartridge = cartridge;
      _isLoading = false;
    });
  }

  void _onStartPressed() {
    if (!_isModeEnabled) {
      showRefreshScentUnavailableSnackBar(context);
      return;
    }
    context.pushRefreshProgress(mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    final detail = RefreshModeDetail.fromMode(mode);

    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '헤어 리프레시 상세',
        onBack: () => context.pop(),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    RefreshDetailPage._horizontalPadding,
                    RefreshDetailPage._gapAppBarToHeader,
                    RefreshDetailPage._horizontalPadding,
                    RefreshDetailPage._gapHeaderToTimeline,
                  ),
                  child: _HeaderSection(
                    modeName: mode.name,
                    careTags: detail.careTags,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: RefreshDetailPage._horizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: RefreshDetailTimeline(
                            totalDurationLabel: detail.totalDurationLabel,
                            steps: detail.steps,
                          ),
                        ),
                        const SizedBox(
                          height: RefreshDetailPage._gapTimelineToPreCheck,
                        ),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: RefreshDetailPage._preCheckMaxWidth,
                            ),
                            child: _PreCheckSection(
                              items: detail.preCheckItems,
                            ),
                          ),
                        ),
                        if (!_isModeEnabled) ...[
                          const SizedBox(height: AppSpacing.md),
                          AppText(
                            RefreshModeAvailability.unavailableReason,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: RefreshDetailPage._gapPreCheckToLink,
                        ),
                        _SelectOtherModeLink(
                          onPressed: () => context.pushReplacementNamed(
                            AppRouteNames.refresh,
                          ),
                        ),
                        const SizedBox(
                          height: RefreshDetailPage._gapLinkToButton,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                    child: AppBoxButton(
                      label: '시작하기',
                      variant: _isModeEnabled
                          ? AppBoxButtonVariant.active
                          : AppBoxButtonVariant.disabled,
                      onPressed: _onStartPressed,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class RefreshDetailPageFallback extends StatelessWidget {
  const RefreshDetailPageFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 상세',
        onBack: () => context.pop(),
      ),
      body: Center(child: AppText('모드 정보를 불러올 수 없어요.')),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.modeName, required this.careTags});

  final String modeName;
  final List<RefreshModeDetailCareTag> careTags;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          modeName,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineL.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: RefreshDetailPage._gapHeaderTitleToTags),
        _CareTagRow(tags: careTags),
      ],
    );
  }
}

class _CareTagRow extends StatelessWidget {
  const _CareTagRow({required this.tags});

  final List<RefreshModeDetailCareTag> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        for (final tag in tags)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                tag.careLabel,
                style: AppTextStyles.bodyM2.copyWith(
                  color: AppColors.gray900,
                  height: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              _IntensityTagChip(label: tag.intensityLabel),
            ],
          ),
      ],
    );
  }
}

class _IntensityTagChip extends StatelessWidget {
  const _IntensityTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gray0,
        border: Border.all(color: AppColors.primary300),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: AppText(
          label,
          style: AppTextStyles.labelM.copyWith(
            color: AppColors.primary500,
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _PreCheckSection extends StatelessWidget {
  const _PreCheckSection({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '진행 전 확인사항',
          style: AppTextStyles.labelL.copyWith(
            color: AppColors.gray800,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppText(
              '- $item',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.gray600,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }
}

class _SelectOtherModeLink extends StatelessWidget {
  const _SelectOtherModeLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: AppColors.gray500,
        ),
        child: AppText(
          '다른 모드 선택하기',
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.gray500,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.gray500,
          ),
        ),
      ),
    );
  }
}
