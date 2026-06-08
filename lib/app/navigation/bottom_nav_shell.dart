import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

class BottomNavShell extends StatelessWidget {
  const BottomNavShell({required this.child, super.key});

  final Widget child;

  static const _tabs = [
    _BottomNavTab(
      label: '홈',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      path: AppRoutePaths.home,
    ),
    _BottomNavTab(
      label: '측정',
      icon: Icons.sensors_outlined,
      selectedIcon: Icons.sensors,
      path: AppRoutePaths.measure,
    ),
    _BottomNavTab(
      label: '리프레시',
      icon: Icons.air_outlined,
      selectedIcon: Icons.air,
      path: AppRoutePaths.refresh,
    ),
    _BottomNavTab(
      label: '기록',
      icon: Icons.history_outlined,
      selectedIcon: Icons.history,
      path: AppRoutePaths.history,
    ),
    _BottomNavTab(
      label: '설정',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      path: AppRoutePaths.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _tabs.indexWhere((tab) => tab.path == location);

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
        onDestinationSelected: (index) => context.go(_tabs[index].path),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _BottomNavTab {
  const _BottomNavTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}
