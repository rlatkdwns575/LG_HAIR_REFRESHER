import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode_filter.dart';

void main() {
  final presets = [
    RefreshMode(
      id: 'before-1',
      name: '외출 전 모드',
      description: '외출 전',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 300,
      icon: Icons.directions_walk_outlined,
    ),
    RefreshMode(
      id: 'after-1',
      name: '외출 후 모드',
      description: '외출 후',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 480,
      icon: Icons.home_outlined,
    ),
    RefreshMode(
      id: 'weather-1',
      name: '날씨 모드',
      description: '날씨',
      category: RefreshModeTabs.weather,
      durationSeconds: 360,
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  final custom = RefreshMode.custom(
    id: 'custom-1',
    name: '나만의 모드',
    description: '커스텀',
    durationMinutes: 4,
  );

  final allModes = [...presets, custom];

  group('filterRefreshModes', () {
    test('전체 탭은 프리셋과 커스텀을 모두 반환한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.allTab,
      );

      expect(result, hasLength(4));
    });

    test('커스텀 모드 탭은 사용자 생성 모드만 반환한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.customMode,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'custom-1');
    });

    test('카테고리 탭은 해당 프리셋만 반환한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.weather,
      );

      expect(result, hasLength(1));
      expect(result.first.id, 'weather-1');
    });

    test('카테고리 탭은 커스텀 모드를 제외한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.beforeOuting,
      );

      expect(result.every((mode) => !mode.isCustom), isTrue);
      expect(result.map((mode) => mode.id), ['before-1']);
    });
  });
}
