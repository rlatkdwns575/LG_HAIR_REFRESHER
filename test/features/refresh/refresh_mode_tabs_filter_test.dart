import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_mode_filter.dart';

void main() {
  final presets = [
    RefreshMode(
      id: 'weather-long',
      name: '날씨 긴 모드',
      description: '날씨',
      category: RefreshModeTabs.weather,
      durationSeconds: 480,
      icon: Icons.wb_sunny_outlined,
    ),
    RefreshMode(
      id: 'before-long',
      name: '외출 전 긴 모드',
      description: '외출 전',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 480,
      icon: Icons.directions_walk_outlined,
    ),
    RefreshMode(
      id: 'before-short',
      name: '외출 전 짧은 모드',
      description: '외출 전',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 120,
      icon: Icons.directions_walk_outlined,
    ),
    RefreshMode(
      id: 'after-1',
      name: '외출 후 모드',
      description: '외출 후',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 300,
      icon: Icons.home_outlined,
    ),
    RefreshMode(
      id: 'weather-short',
      name: '날씨 짧은 모드',
      description: '날씨',
      category: RefreshModeTabs.weather,
      durationSeconds: 180,
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  final customOld = RefreshMode.custom(
    id: 'custom-old',
    name: '이전 커스텀',
    description: '커스텀',
    durationMinutes: 4,
  ).copyWith(createdAt: DateTime(2026, 1, 1));

  final customNew = RefreshMode.custom(
    id: 'custom-new',
    name: '최신 커스텀',
    description: '커스텀',
    durationMinutes: 5,
  ).copyWith(createdAt: DateTime(2026, 6, 1));

  final allModes = [...presets, customOld, customNew];

  group('filterRefreshModes', () {
    test('전체 탭은 커스텀을 제외하고 카테고리·소요시간 순으로 정렬한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.allTab,
      );

      expect(result, hasLength(5));
      expect(result.every((mode) => !mode.isCustom), isTrue);
      expect(result.map((mode) => mode.id), [
        'before-short',
        'before-long',
        'after-1',
        'weather-short',
        'weather-long',
      ]);
    });

    test('커스텀 모드 탭은 사용자 생성 모드만 최신순으로 반환한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.customModeTab,
      );

      expect(result.map((mode) => mode.id), ['custom-new', 'custom-old']);
    });

    test('카테고리 탭은 해당 카테고리만 소요시간 오름차순으로 반환한다', () {
      final result = filterRefreshModes(
        allModes: allModes,
        selectedTab: RefreshModeTabs.beforeOuting,
      );

      expect(result.map((mode) => mode.id), ['before-short', 'before-long']);
    });

    test('카테고리가 일치하는 커스텀 모드도 카테고리 탭에 포함된다', () {
      final customBefore = RefreshMode.custom(
        id: 'custom-before',
        name: '커스텀 외출 전',
        description: '커스텀',
        durationMinutes: 5,
      ).copyWith(category: RefreshModeTabs.beforeOuting, durationSeconds: 600);

      final result = filterRefreshModes(
        allModes: [...allModes, customBefore],
        selectedTab: RefreshModeTabs.beforeOuting,
      );

      expect(result.map((mode) => mode.id), [
        'before-short',
        'before-long',
        'custom-before',
      ]);
    });

    test('기타 탭은 기타 카테고리만 소요시간 오름차순으로 반환한다', () {
      final etcShort = RefreshMode(
        id: 'etc-short',
        name: '기타 짧은',
        description: '기타',
        category: RefreshModeTabs.etc,
        durationSeconds: 120,
        icon: Icons.auto_awesome_outlined,
      );
      final etcLong = RefreshMode(
        id: 'etc-long',
        name: '기타 긴',
        description: '기타',
        category: RefreshModeTabs.etc,
        durationSeconds: 480,
        icon: Icons.auto_awesome_outlined,
      );

      final result = filterRefreshModes(
        allModes: [...allModes, etcShort, etcLong],
        selectedTab: RefreshModeTabs.etc,
      );

      expect(result.map((mode) => mode.id), ['etc-short', 'etc-long']);
    });
  });
}
