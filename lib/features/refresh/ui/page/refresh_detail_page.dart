import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/model/refresh_mode_detail.dart';
import '../widgets/refresh_detail_timeline.dart';

/// Figma Design `리프레시 상세` (833:14941 · 823:26534 · 833:15046).
class RefreshDetailPage extends StatelessWidget {
  const RefreshDetailPage({required this.mode, super.key});

  final RefreshMode mode;

  static const double _horizontalPadding = 28;
  static const double _topInset = 56;
  static const double _topInsetThreeSteps = 44;
  static const double _headerToTimeline = 116;
  static const double _headerToTimelineThreeSteps = 88;
  static const double _timelineToPrecheckMin = 48;

  static double _topInsetFor(int stepCount) =>
      stepCount >= 3 ? _topInsetThreeSteps : _topInset;

  static double _headerToTimelineFor(int stepCount) =>
      stepCount >= 3 ? _headerToTimelineThreeSteps : _headerToTimeline;

  @override
  Widget build(BuildContext context) {
    final detail = RefreshModeDetail.fromMode(mode);
    final stepCount = detail.steps.length;

    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 상세',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: _horizontalPadding,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: _topInsetFor(stepCount)),
                            _HeaderSection(
                              modeName: mode.name,
                              careTags: detail.careTags,
                            ),
                            SizedBox(height: _headerToTimelineFor(stepCount)),
                            RefreshDetailTimeline(
                              totalDurationLabel: detail.totalDurationLabel,
                              steps: detail.steps,
                            ),
                            const Spacer(),
                            const SizedBox(height: _timelineToPrecheckMin),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 320,
                                ),
                                child: _PreCheckSection(
                                  items: detail.preCheckItems,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _SelectOtherModeLink(
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, AppSpacing.md, 15, 20),
              child: AppBoxButton(
                label: '시작하기',
                onPressed: () => context.pushRefreshProgress(mode: mode),
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
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '리프레시 상세',
        onBack: () => context.pop(),
      ),
      body: const Center(child: Text('모드 정보를 불러올 수 없어요.')),
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
        Text(
          modeName,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineL.copyWith(
            color: AppColors.gray900,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
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
              Text(
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
        child: Text(
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
        Text(
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
            child: Text(
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
        child: Text(
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
