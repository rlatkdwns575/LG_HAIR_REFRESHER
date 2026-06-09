import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_list_item.dart';
import '../../../../shared/widgets/app_top_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppTopHeader(
        title: 'LG ThinQ',
        actions: [
          IconButton(
            tooltip: '설정',
            onPressed: context.pushSettings,
            icon: const Icon(
              Icons.settings_outlined,
              color: AppComponentColors.headerTitle,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        children: [
          _HomeSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppListItem(title: '헤어상태 진단', onTap: context.pushMeasure),
                const SizedBox(height: AppSpacing.md),
                AppBoxButton(label: '진단하기', onPressed: context.pushMeasure),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _HomeSectionCard(
            child: AppListItem(title: '헤어 리프레시', onTap: context.pushRefresh),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: TextButton(
              onPressed: context.pushHistory,
              child: const Text('기록 보러가기'),
            ),
          ),
        ],
      ),
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              heroTag: 'widgetGallery',
              tooltip: 'Shared Widget Gallery',
              backgroundColor: AppComponentColors.buttonActiveBackground,
              foregroundColor: AppComponentColors.buttonActiveText,
              onPressed: context.pushWidgetGallery,
              child: const Icon(Icons.widgets_outlined, size: 20),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: child,
      ),
    );
  }
}
