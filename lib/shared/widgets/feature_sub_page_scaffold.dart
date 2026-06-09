import 'package:flutter/material.dart';

import 'feature_placeholder_page.dart';

/// 홈 허브에서 push로 진입하는 feature 화면용 스캐폴드.
class FeatureSubPageScaffold extends StatelessWidget {
  const FeatureSubPageScaffold({
    required this.title,
    required this.description,
    required this.items,
    super.key,
  });

  final String title;
  final String description;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: Text(title)),
      body: FeaturePlaceholderPage(
        title: title,
        description: description,
        items: items,
      ),
    );
  }
}
