import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_top_header.dart';
import 'feature_placeholder_page.dart';

/// 홈 허브에서 push로 진입하는 feature 화면용 스캐폴드.
class FeatureSubPageScaffold extends StatelessWidget {
  const FeatureSubPageScaffold({
    required this.title,
    required this.description,
    required this.items,
    this.onBack,
    super.key,
  });

  final String title;
  final String description;
  final List<String> items;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppTopHeader(
        title: title,
        leading: onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.gray800),
                onPressed: onBack,
              )
            : BackButton(color: AppColors.gray800),
      ),
      body: FeaturePlaceholderPage(
        title: title,
        description: description,
        items: items,
      ),
    );
  }
}
