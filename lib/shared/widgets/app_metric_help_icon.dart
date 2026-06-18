import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_text.dart';

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
    this.size = 14,
    this.placement = AppMetricHelpTooltipPlacement.belowEnd,
    this.tooltipMaxWidth = 220,
    this.labelIconGap = 2,
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

  final GlobalKey _iconKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isVisible = false;

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
    if (widget.tooltipMessage.isEmpty) {
      return;
    }

    _activeTooltip?._hideTooltip(notifyActive: false);
    _activeTooltip = this;

    final box = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }

    final overlay = Overlay.of(context);
    final iconTopLeft = box.localToGlobal(Offset.zero);
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

        final left = switch (widget.placement) {
          AppMetricHelpTooltipPlacement.belowStart => _belowStartLeft(
            iconTopLeft: iconTopLeft,
            tooltipMaxWidth: tooltipMaxWidth,
            screenWidth: screenSize.width,
          ),
          AppMetricHelpTooltipPlacement.belowEnd => _belowEndLeft(
            iconTopLeft: iconTopLeft,
            iconWidth: box.size.width,
            tooltipMaxWidth: tooltipMaxWidth,
            screenWidth: screenSize.width,
          ),
        };

        var top = iconTopLeft.dy + box.size.height + verticalGap;
        if (top + estimatedHeight > safeBottom) {
          top = safeBottom - estimatedHeight;
        }
        top = top.clamp(safeTop, safeBottom - estimatedHeight);

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideTooltip,
              ),
            ),
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

  double _belowStartLeft({
    required Offset iconTopLeft,
    required double tooltipMaxWidth,
    required double screenWidth,
  }) {
    var left = iconTopLeft.dx;
    if (left + tooltipMaxWidth > screenWidth - 16) {
      left = screenWidth - tooltipMaxWidth - 16;
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

  Widget _buildIcon() {
    return Container(
      key: _iconKey,
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
