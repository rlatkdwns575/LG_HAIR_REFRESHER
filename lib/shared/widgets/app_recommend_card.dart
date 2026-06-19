import 'package:flutter/material.dart';

import '../../app/theme/app_component_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import 'app_capsule_button.dart';
import 'app_text.dart';

/// Figma `card_recommend` — recommendation message with capsule CTA.
class AppRecommendCard extends StatelessWidget {
  const AppRecommendCard({
    required this.message,
    required this.actionLabel,
    required this.onActionPressed,
    this.actionIcon = Icons.chevron_right,
    super.key,
  });

  final String message;
  final String actionLabel;
  final VoidCallback? onActionPressed;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppComponentColors.recommendCardGradientStart,
            AppComponentColors.recommendCardGradientEnd,
          ],
        ),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: const Alignment(-0.2, 0.9),
            end: const Alignment(0.8, 0.1),
            colors: [
              AppComponentColors.recommendCardBorderStart,
              AppComponentColors.recommendCardBorderEnd,
            ],
          ),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            AppText(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyS.copyWith(
                color: AppComponentColors.recommendCardText,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCapsuleButton(
              label: actionLabel,
              icon: actionIcon,
              iconPosition: AppCapsuleButtonIconPosition.right,
              onPressed: onActionPressed,
            ),
          ],
        ),
      ),
    );
  }
}

/// Border with gradient stroke for recommend card.
class GradientBoxBorder extends BoxBorder {
  const GradientBoxBorder({required this.gradient, this.width = 1});

  final Gradient gradient;
  final double width;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (width <= 0) {
      return;
    }

    // Stroke is centered on the path — inset so the full width stays inside bounds.
    final inset = width / 2;
    final innerRect = rect.deflate(inset);
    final resolvedRadius =
        borderRadius?.resolve(textDirection) ?? BorderRadius.zero;
    final rrect = resolvedRadius.toRRect(innerRect);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawRRect(rrect, paint);
  }

  @override
  ShapeBorder scale(double t) =>
      GradientBoxBorder(gradient: gradient, width: width * t);
}
