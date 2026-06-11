import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/features/refresh/data/api/refresh_recommend_fallback.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';

void main() {
  final candidates = [
    RefreshMode(
      id: 'before-1',
      name: '외출 전',
      description: '외출 전',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 300,
      icon: Icons.directions_walk_outlined,
    ),
    RefreshMode(
      id: 'after-1',
      name: '외출 후',
      description: '외출 후',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 480,
      icon: Icons.home_outlined,
    ),
    RefreshMode(
      id: 'weather-1',
      name: '날씨',
      description: '날씨',
      category: RefreshModeTabs.weather,
      durationSeconds: 360,
      icon: Icons.wb_sunny_outlined,
    ),
  ];

  group('RefreshRecommendFallback.pickMode', () {
    test('비·눈 날씨면 날씨 카테고리를 우선한다', () {
      final mode = RefreshRecommendFallback.pickMode(
        candidates: candidates,
        environment: const EnvironmentSnapshot(
          temperatureCelsius: 18,
          humidityPercent: 50,
          isRaining: true,
          isSnowing: false,
        ),
      );

      expect(mode?.id, 'weather-1');
    });

    test('높은 습도면 외출 후 카테고리를 우선한다', () {
      final mode = RefreshRecommendFallback.pickMode(
        candidates: candidates,
        environment: const EnvironmentSnapshot(
          temperatureCelsius: 24,
          humidityPercent: 75,
          isRaining: false,
          isSnowing: false,
        ),
      );

      expect(mode?.id, 'after-1');
    });

    test('기본 조건이면 외출 전 카테고리를 우선한다', () {
      final mode = RefreshRecommendFallback.pickMode(
        candidates: candidates,
        environment: const EnvironmentSnapshot(
          temperatureCelsius: 22,
          humidityPercent: 45,
          isRaining: false,
          isSnowing: false,
        ),
      );

      expect(mode?.id, 'before-1');
    });

    test('후보가 비어 있으면 null을 반환한다', () {
      final mode = RefreshRecommendFallback.pickMode(
        candidates: const [],
        environment: const EnvironmentSnapshot(
          temperatureCelsius: 22,
          humidityPercent: 45,
          isRaining: false,
          isSnowing: false,
        ),
      );

      expect(mode, isNull);
    });
  });
}
