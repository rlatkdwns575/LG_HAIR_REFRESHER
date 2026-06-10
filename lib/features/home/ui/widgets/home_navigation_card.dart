import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_capsule_button.dart';

/// Figma 홈 액션 카드 — 개별 흰색 카드 (710:17738 Frame 4941/4940/4944).
class HomeActionCard extends StatelessWidget {
  const HomeActionCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: child,
      ),
    );
  }
}

class HomeNavigationCard extends StatelessWidget {
  const HomeNavigationCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return HomeActionCard(child: child);
  }
}

class HomeNavigationRow extends StatelessWidget {
  const HomeNavigationRow({
    required this.title,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleM.copyWith(
                color: AppColors.gray800,
                fontSize: 16,
                height: 22 / 16,
              ),
            ),
          ),
          trailing ??
              const Icon(
                Icons.chevron_right,
                size: 24,
                color: AppComponentColors.listChevron,
              ),
        ],
      ),
    );
  }
}

class HomeDiagnosisRow extends StatelessWidget {
  const HomeDiagnosisRow({required this.onDiagnosisPressed, super.key});

  final VoidCallback? onDiagnosisPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '헤어 상태 진단',
              style: AppTextStyles.titleM.copyWith(
                color: AppColors.gray800,
                fontSize: 16,
                height: 22 / 16,
              ),
            ),
          ),
          AppCapsuleButton(label: '진단하기', onPressed: onDiagnosisPressed),
        ],
      ),
    );
  }
}

class HomeTappableNavigationRow extends StatelessWidget {
  const HomeTappableNavigationRow({
    required this.title,
    required this.onTap,
    super.key,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: HomeNavigationRow(title: title, onTap: onTap),
      ),
    );
  }
}
