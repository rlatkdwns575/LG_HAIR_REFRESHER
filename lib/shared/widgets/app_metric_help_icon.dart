import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text.dart';

enum AppMetricHelpTooltipPlacement {
  /// ? 아이콘 오른쪽에 바로 붙여 표시.
  besideIcon,

  /// ? 아이콘 아래, 오른쪽 정렬.
  belowEnd,
}

/// 진단·리프레시 결과 상세 — ? 도움말 아이콘 + 호버/탭 툴팁.
class AppMetricHelpIcon extends StatefulWidget {
  const AppMetricHelpIcon({
    required this.tooltipMessage,
    this.size = 14,
    this.placement = AppMetricHelpTooltipPlacement.besideIcon,
    this.tooltipMaxWidth = 220,
    super.key,
  });

  final String tooltipMessage;
  final double size;
  final AppMetricHelpTooltipPlacement placement;
  final double tooltipMaxWidth;

  @override
  State<AppMetricHelpIcon> createState() => _AppMetricHelpIconState();
}

class _AppMetricHelpIconState extends State<AppMetricHelpIcon> {
  OverlayEntry? _overlayEntry;
  bool _hovering = false;
  bool _pressing = false;

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  void _updateTooltipVisibility() {
    if (_hovering || _pressing) {
      _showTooltip();
    } else {
      _hideTooltip();
    }
  }

  void _showTooltip() {
    if (widget.tooltipMessage.isEmpty || _overlayEntry != null) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }

    final overlay = Overlay.of(context);
    final iconTopLeft = box.localToGlobal(Offset.zero);
    const horizontalGap = 4.0;
    const verticalGap = 6.0;
    final tooltipMaxWidth = widget.tooltipMaxWidth;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final mediaQuery = MediaQuery.of(overlayContext);
        final screenSize = mediaQuery.size;
        final safeTop = mediaQuery.padding.top + 8;
        final safeBottom = screenSize.height - mediaQuery.padding.bottom - 8;
        final estimatedHeight = _estimateTooltipHeight(
          message: widget.tooltipMessage,
          maxWidth: tooltipMaxWidth,
        );

        late final double left;
        late final double top;

        switch (widget.placement) {
          case AppMetricHelpTooltipPlacement.besideIcon:
            left = _besideIconLeft(
              iconTopLeft: iconTopLeft,
              iconWidth: box.size.width,
              tooltipMaxWidth: tooltipMaxWidth,
              screenWidth: screenSize.width,
              horizontalGap: horizontalGap,
            );
            top = iconTopLeft.dy.clamp(safeTop, safeBottom - estimatedHeight);
          case AppMetricHelpTooltipPlacement.belowEnd:
            left = _belowEndLeft(
              iconTopLeft: iconTopLeft,
              iconWidth: box.size.width,
              tooltipMaxWidth: tooltipMaxWidth,
              screenWidth: screenSize.width,
            );
            final belowTop = iconTopLeft.dy + box.size.height + verticalGap;
            if (belowTop + estimatedHeight <= safeBottom) {
              top = belowTop;
            } else {
              top = (iconTopLeft.dy - estimatedHeight - verticalGap).clamp(
                safeTop,
                safeBottom - estimatedHeight,
              );
            }
        }

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
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
                        widget.tooltipMessage,
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
  }

  double _estimateTooltipHeight({
    required String message,
    required double maxWidth,
  }) {
    const horizontalPadding = 24.0;
    const verticalPadding = 20.0;
    const lineHeight = 18.0;
    const averageCharWidth = 11.0;

    final contentWidth = maxWidth - horizontalPadding;
    final charsPerLine = (contentWidth / averageCharWidth).floor().clamp(
      1,
      999,
    );
    final lineCount = (message.length / charsPerLine).ceil().clamp(1, 999);

    return verticalPadding + lineCount * lineHeight;
  }

  double _besideIconLeft({
    required Offset iconTopLeft,
    required double iconWidth,
    required double tooltipMaxWidth,
    required double screenWidth,
    required double horizontalGap,
  }) {
    var left = iconTopLeft.dx + iconWidth + horizontalGap;
    if (left + tooltipMaxWidth > screenWidth - 16) {
      left = iconTopLeft.dx - tooltipMaxWidth - horizontalGap;
    }
    if (left < 16) {
      left = 16;
    }
    return left;
  }

  double _belowEndLeft({
    required Offset iconTopLeft,
    required double iconWidth,
    required double tooltipMaxWidth,
    required double screenWidth,
  }) {
    var left = iconTopLeft.dx + iconWidth - tooltipMaxWidth;
    if (left + tooltipMaxWidth > screenWidth - 16) {
      left = screenWidth - tooltipMaxWidth - 16;
    }
    if (left < 16) {
      left = 16;
    }
    return left;
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final icon = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppComponentColors.helpIcon),
      ),
      alignment: Alignment.center,
      child: AppText(
        '?',
        style: AppTextStyles.labelXs.copyWith(
          color: AppComponentColors.helpIcon,
          fontSize: 10,
          height: 1,
        ),
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.help,
      onEnter: (_) {
        _hovering = true;
        _updateTooltipVisibility();
      },
      onExit: (_) {
        _hovering = false;
        _updateTooltipVisibility();
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) {
          _pressing = true;
          _updateTooltipVisibility();
        },
        onPointerUp: (_) {
          _pressing = false;
          _updateTooltipVisibility();
        },
        onPointerCancel: (_) {
          _pressing = false;
          _updateTooltipVisibility();
        },
        child: icon,
      ),
    );
  }
}
