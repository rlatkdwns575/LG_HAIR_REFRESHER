import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text.dart';

/// Figma help icon — 13.333×13.333, Gray-500 (#8B939E).
const appMetricHelpIconSize = 40 / 3;

const _helpIconSvgPath =
    'M7.225 10.425C7.38611 10.2639 7.46667 10.0667 7.46667 9.83333C7.46667 9.6 7.38611 9.40278 7.225 9.24167C7.06389 9.08055 6.86667 9 6.63333 9C6.4 9 6.20278 9.08055 6.04167 9.24167C5.88056 9.40278 5.8 9.6 5.8 9.83333C5.8 10.0667 5.88056 10.2639 6.04167 10.425C6.20278 10.5861 6.4 10.6667 6.63333 10.6667C6.86667 10.6667 7.06389 10.5861 7.225 10.425ZM6.66667 13.3333C5.74444 13.3333 4.87778 13.1583 4.06667 12.8083C3.25556 12.4583 2.55 11.9833 1.95 11.3833C1.35 10.7833 0.875 10.0778 0.525 9.26667C0.175 8.45555 0 7.58889 0 6.66667C0 5.74444 0.175 4.87778 0.525 4.06667C0.875 3.25556 1.35 2.55 1.95 1.95C2.55 1.35 3.25556 0.875 4.06667 0.525C4.87778 0.175 5.74444 0 6.66667 0C7.58889 0 8.45555 0.175 9.26667 0.525C10.0778 0.875 10.7833 1.35 11.3833 1.95C11.9833 2.55 12.4583 3.25556 12.8083 4.06667C13.1583 4.87778 13.3333 5.74444 13.3333 6.66667C13.3333 7.58889 13.1583 8.45555 12.8083 9.26667C12.4583 10.0778 11.9833 10.7833 11.3833 11.3833C10.7833 11.9833 10.0778 12.4583 9.26667 12.8083C8.45555 13.1583 7.58889 13.3333 6.66667 13.3333ZM6.66667 12C8.15555 12 9.41667 11.4833 10.45 10.45C11.4833 9.41667 12 8.15555 12 6.66667C12 5.17778 11.4833 3.91667 10.45 2.88333C9.41667 1.85 8.15555 1.33333 6.66667 1.33333C5.17778 1.33333 3.91667 1.85 2.88333 2.88333C1.85 3.91667 1.33333 5.17778 1.33333 6.66667C1.33333 8.15555 1.85 9.41667 2.88333 10.45C3.91667 11.4833 5.17778 12 6.66667 12ZM6.73333 3.8C7.01111 3.8 7.25278 3.88889 7.45833 4.06667C7.66389 4.24444 7.76667 4.46667 7.76667 4.73333C7.76667 4.97778 7.69167 5.19444 7.54167 5.38333C7.39167 5.57222 7.22222 5.75 7.03333 5.91667C6.77778 6.13889 6.55278 6.38333 6.35833 6.65C6.16389 6.91667 6.06667 7.21667 6.06667 7.55C6.06667 7.70555 6.125 7.83611 6.24167 7.94167C6.35833 8.04722 6.49444 8.1 6.65 8.1C6.81667 8.1 6.95833 8.04444 7.075 7.93333C7.19167 7.82222 7.26667 7.68333 7.3 7.51667C7.34444 7.28333 7.44444 7.075 7.6 6.89167C7.75556 6.70833 7.92222 6.53333 8.1 6.36667C8.35556 6.12222 8.575 5.85556 8.75833 5.56667C8.94167 5.27778 9.03333 4.95556 9.03333 4.6C9.03333 4.03333 8.80278 3.56944 8.34167 3.20833C7.88056 2.84722 7.34444 2.66667 6.73333 2.66667C6.31111 2.66667 5.90833 2.75556 5.525 2.93333C5.14167 3.11111 4.85 3.38333 4.65 3.75C4.57222 3.88333 4.54722 4.025 4.575 4.175C4.60278 4.325 4.67778 4.43889 4.8 4.51667C4.95556 4.60556 5.11667 4.63333 5.28333 4.6C5.45 4.56667 5.58889 4.47222 5.7 4.31667C5.82222 4.15 5.975 4.02222 6.15833 3.93333C6.34167 3.84444 6.53333 3.8 6.73333 3.8Z';

enum AppMetricHelpTooltipPlacement {
  /// ? 아이콘 아래, 왼쪽 정렬.
  belowStart,

  /// ? 아이콘 아래, 오른쪽 정렬.
  belowEnd,
}

/// 진단·리프레시 결과 상세 — 라벨/? 탭으로 도움말 표시, 바깥 탭 시 닫힘.
class AppMetricHelpIcon extends StatefulWidget {
  const AppMetricHelpIcon({
    required this.tooltipMessage,
    this.label,
    this.labelStyle,
    this.size = appMetricHelpIconSize,
    this.placement = AppMetricHelpTooltipPlacement.belowEnd,
    this.tooltipMaxWidth = 220,
    this.labelIconGap = 4,
    super.key,
  });

  final String tooltipMessage;
  final String? label;
  final TextStyle? labelStyle;
  final double size;
  final AppMetricHelpTooltipPlacement placement;
  final double tooltipMaxWidth;
  final double labelIconGap;

  @override
  State<AppMetricHelpIcon> createState() => _AppMetricHelpIconState();
}

class _AppMetricHelpIconState extends State<AppMetricHelpIcon> {
  static _AppMetricHelpIconState? _activeTooltip;

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

  static const _verticalGap = 6.0;

  @override
  void dispose() {
    _hideTooltip(notifyActive: true);
    super.dispose();
  }

  void _toggleTooltip() {
    if (_isVisible) {
      _hideTooltip();
    } else {
      _showTooltip();
    }
  }

  void _showTooltip() {
    final displayMessage = _displayTooltipMessage;
    if (displayMessage.isEmpty) {
      return;
    }

    _activeTooltip?._hideTooltip(notifyActive: false);
    _activeTooltip = this;

    final overlay = Overlay.of(context);
    final placement = widget.placement;
    final tooltipMaxWidth = widget.tooltipMaxWidth;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideTooltip,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: switch (placement) {
                AppMetricHelpTooltipPlacement.belowStart =>
                  Alignment.bottomLeft,
                AppMetricHelpTooltipPlacement.belowEnd => Alignment.bottomRight,
              },
              followerAnchor: switch (placement) {
                AppMetricHelpTooltipPlacement.belowStart => Alignment.topLeft,
                AppMetricHelpTooltipPlacement.belowEnd => Alignment.topRight,
              },
              offset: const Offset(0, _verticalGap),
              child: IgnorePointer(
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: tooltipMaxWidth),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray0,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        boxShadow: AppShadows.soft,
                      ),
                      child: AppText(
                        displayMessage,
                        style: AppTextStyles.bodyXs.copyWith(
                          color: AppColors.gray700,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isVisible = true);
  }

  void _hideTooltip({bool notifyActive = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (notifyActive && _activeTooltip == this) {
      _activeTooltip = null;
    }
    if (_isVisible && mounted) {
      setState(() => _isVisible = false);
    } else {
      _isVisible = false;
    }
  }

  String get _displayTooltipMessage => widget.tooltipMessage
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  Widget _buildIcon() {
    final size = widget.size;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: size,
        height: size,
        child: SvgPicture.string(
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 14 14" fill="none">'
          '<path d="$_helpIconSvgPath" fill="#8B939E"/>'
          '</svg>',
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            AppColors.gray500,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final labelStyle = widget.labelStyle;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggleTooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null && labelStyle != null) ...[
            Flexible(child: AppText(label, style: labelStyle)),
            SizedBox(width: widget.labelIconGap),
          ],
          _buildIcon(),
        ],
      ),
    );
  }
}
