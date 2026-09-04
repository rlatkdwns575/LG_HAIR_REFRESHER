import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_battery_status.dart';
import '../../../../shared/widgets/app_text_link_button.dart';
import '../../data/home_assets.dart';
import '../../data/model/home_dashboard_data.dart';
import '../../data/model/home_filter_status.dart';
import 'home_device_hero_header.dart';

/// Figma 홈 img · 360×293.5 · status top:280(14px overlap) · content top:368.
///
/// 화면 전체 너비 기준 반응형(540dp 초과 시에도 비율 유지 확대) · 홈 하단 콘텐츠만 540dp 제한.
class HomeDeviceStatusSection extends StatefulWidget {
  const HomeDeviceStatusSection({
    required this.data,
    this.onDeviceManagePressed,
    this.onSettingsPressed,
    super.key,
  });

  final HomeDashboardData data;
  final VoidCallback? onDeviceManagePressed;
  final VoidCallback? onSettingsPressed;

  static const baseHeroHeight = 368.0;
  static const baseImageHeight = 293.5;
  static const baseStatusTop = 280.0;
  static const statusIconSize = 24.0;
  static const statusLabelColor = AppColors.gray700;

  @override
  State<HomeDeviceStatusSection> createState() =>
      _HomeDeviceStatusSectionState();
}

class _HomeDeviceStatusSectionState extends State<HomeDeviceStatusSection> {
  static const _heroBackground = AppColors.homeBackground;
  static const _deviceManageButtonPadding = EdgeInsets.fromLTRB(
    16,
    AppSpacing.xs,
    9,
    AppSpacing.xs,
  );

  double? _aspectRatio;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aspectRatio != null) {
      return;
    }

    _imageStream = AssetImage(
      HomeAssets.deviceImage,
    ).resolve(createLocalImageConfiguration(context));
    _imageListener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) {
        return;
      }
      setState(() {
        _aspectRatio = info.image.width / info.image.height;
      });
    });
    _imageStream!.addListener(_imageListener!);
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  _HeroLayoutMetrics _metricsForWidth(double width) {
    const baseImageHeight = HomeDeviceStatusSection.baseImageHeight;
    const baseStatusTop = HomeDeviceStatusSection.baseStatusTop;
    const baseHeroHeight = HomeDeviceStatusSection.baseHeroHeight;

    if (_aspectRatio == null) {
      return _HeroLayoutMetrics(
        imageHeight: baseImageHeight,
        statusTop: baseStatusTop,
        heroHeight: baseHeroHeight,
      );
    }

    final naturalWidth = baseImageHeight * _aspectRatio!;
    if (width <= naturalWidth) {
      return _HeroLayoutMetrics(
        imageHeight: baseImageHeight,
        statusTop: baseStatusTop,
        heroHeight: baseHeroHeight,
      );
    }

    final scale = width / naturalWidth;
    return _HeroLayoutMetrics(
      imageHeight: baseImageHeight * scale,
      statusTop: baseStatusTop * scale,
      heroHeight: baseHeroHeight * scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _metricsForWidth(constraints.maxWidth);

        return SizedBox(
          width: double.infinity,
          height: metrics.heroHeight,
          child: DecoratedBox(
            decoration: const BoxDecoration(color: _heroBackground),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: metrics.imageHeight,
                  child: Image.asset(
                    HomeAssets.deviceImage,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    width: constraints.maxWidth,
                    height: metrics.imageHeight,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: HomeDeviceHeroHeader(
                    title: widget.data.deviceName,
                    onSettingsPressed: widget.onSettingsPressed,
                  ),
                ),
                Positioned(
                  top: metrics.statusTop,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: SizedBox(
                          width: 240,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: AppBatteryStatus(
                                    percent: widget.data.batteryPercent,
                                    iconAsset: HomeAssets.batteryIconFor(
                                      widget.data.batteryPercent,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 120,
                                child: Center(
                                  child: _FilterStatus(
                                    status: widget.data.filterStatus,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: AppTextLinkButton(
                          label: '디바이스 관리',
                          onPressed: widget.onDeviceManagePressed,
                          contentPadding: _deviceManageButtonPadding,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroLayoutMetrics {
  const _HeroLayoutMetrics({
    required this.imageHeight,
    required this.statusTop,
    required this.heroHeight,
  });

  final double imageHeight;
  final double statusTop;
  final double heroHeight;
}

class _FilterStatus extends StatelessWidget {
  const _FilterStatus({required this.status});

  final HomeFilterStatus status;

  static Color _statusColor(HomeFilterStatusTier tier) {
    return switch (tier) {
      HomeFilterStatusTier.replaceSoon => AppColors.red800,
      HomeFilterStatusTier.replaceRecommended => AppColors.orange700,
      HomeFilterStatusTier.normal => AppColors.gray600,
      HomeFilterStatusTier.fresh => AppColors.safe500,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              HomeAssets.filterIcon,
              width: HomeDeviceStatusSection.statusIconSize,
              height: HomeDeviceStatusSection.statusIconSize,
            ),
            const SizedBox(width: AppSpacing.xs),
            AppText(
              '필터 상태',
              style: AppTextStyles.bodyS.copyWith(
                color: HomeDeviceStatusSection.statusLabelColor,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            AppText(
              status.label,
              style: AppTextStyles.bodyS.copyWith(
                color: _statusColor(status.tier),
                fontSize: 13,
                height: 18 / 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
