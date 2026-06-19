import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/auth_session_service.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../shared/models/scent_cartridge_status.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/api/custom_mode_api.dart';
import '../../data/custom_mode_cache.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/model/refresh_mode_detail.dart';
import '../../data/refresh_assets.dart';
import '../../data/refresh_mode_availability.dart';
import '../refresh_scent_unavailable.dart';
import '../widgets/refresh_detail_timeline.dart';

/// Figma Design `리프레시 상세` (40000026:25130).
class RefreshDetailPage extends StatefulWidget {
  const RefreshDetailPage({required this.mode, super.key});

  final RefreshMode mode;

  static const double _horizontalPadding = 15;
  static const double _preCheckMaxWidth = 279;

  /// Figma 40000026:25012 — 앱바 ↔ 모드명.
  static const double _gapAppBarToHeader = 56;

  /// Figma 40000026:25012 — 모드명 ↔ 태그 행.
  static const double _gapHeaderTitleToTags = 18;

  /// 태그 행 ↔ 타임라인 블록.
  static const double _gapHeaderToTimeline = 32;

  /// 타임라인 블록 ↔ 확인사항.
  static const double _gapTimelineToPreCheck = 56;

  /// Figma 40000026:25012 — 확인사항 ↔ 다른 모드 링크.
  static const double _gapPreCheckToLink = 48;

  /// Figma 40000026:25012 — 링크 ↔ 시작하기 버튼.
  static const double _gapLinkToButton = 20;

  @override
  State<RefreshDetailPage> createState() => _RefreshDetailPageState();
}

class _RefreshDetailPageState extends State<RefreshDetailPage> {
  final _deviceConsumableService = const DeviceConsumableService();
  final _customModeApi = const CustomModeApi();

  ScentCartridgeStatus _scentCartridge = ScentCartridgeStatus.notAttached;
  bool _isLoading = true;
  bool _isDeleting = false;

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

  Future<void> _confirmDeleteMode() async {
    if (!mode.isDeletable || _isDeleting) {
      return;
    }

    final confirmed = await AppConfirmDialog.show(
      context,
      title: '해당 모드를 삭제하시겠습니까?',
      message: '모드를 삭제하면\n더 이상 해당 모드를 사용할 수 없습니다.',
      primaryLabel: '삭제',
      secondaryLabel: '취소',
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() => _isDeleting = true);

    final userId = AuthSessionService.resolveUserId();
    final deleted = await _customModeApi.delete(
      userId: userId,
      modeId: mode.id,
    );

    if (!mounted) {
      return;
    }

    setState(() => _isDeleting = false);

    if (deleted && CustomModeCache.instance.removeById(mode.id)) {
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = RefreshModeDetail.fromMode(mode);

    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 상세',
        onBack: () => context.pop(),
        actions: [
          if (mode.isDeletable)
            IconButton(
              onPressed: _isDeleting ? null : _confirmDeleteMode,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Image.asset(
                RefreshAssets.trashIcon,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      RefreshDetailPage._horizontalPadding,
                      RefreshDetailPage._gapAppBarToHeader,
                      RefreshDetailPage._horizontalPadding,
                      0,
                    ),
                    children: [
                      _HeaderSection(
                        modeName: mode.name,
                        careTags: detail.careTags,
                      ),
                      const SizedBox(
                        height: RefreshDetailPage._gapHeaderToTimeline,
                      ),
                      RefreshDetailTimeline(
                        totalDurationLabel: detail.totalDurationLabel,
                        steps: detail.steps,
                      ),
                      const SizedBox(
                        height: RefreshDetailPage._gapTimelineToPreCheck,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: RefreshDetailPage._preCheckMaxWidth,
                          child: _PreCheckSection(items: detail.preCheckItems),
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
                        onPressed: () =>
                            context.pushReplacementNamed(AppRouteNames.refresh),
                      ),
                      const SizedBox(
                        height: RefreshDetailPage._gapLinkToButton,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    15,
                    10,
                    15,
                    20 + AppSystemInsets.bottomOf(context),
                  ),
                  child: AppBoxButton(
                    label: '시작하기',
                    variant: _isModeEnabled
                        ? AppBoxButtonVariant.active
                        : AppBoxButtonVariant.disabled,
                    onPressed: _onStartPressed,
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
            height: 34 / 28,
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
      spacing: 16,
      runSpacing: AppSpacing.sm,
      children: [
        for (final tag in tags)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppText(
                tag.careLabel,
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.gray900,
                  height: 16 / 12,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
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
        border: Border.all(color: AppColors.primary400),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: SizedBox(
        height: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Center(
            child: AppText(
              label,
              style: AppTextStyles.labelXs.copyWith(
                fontSize: 10,
                height: 1,
                color: AppColors.primary500,
                fontWeight: FontWeight.w500,
              ),
            ),
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
          style: AppTextStyles.bodyXs.copyWith(
            color: AppColors.gray600,
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: AppText(
              '- $item',
              style: AppTextStyles.bodyXs.copyWith(
                color: AppColors.gray600,
                height: 16 / 12,
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              '다른 모드 선택하기',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.gray500,
                height: 16 / 12,
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.gray500),
          ],
        ),
      ),
    );
  }
}
