import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/model/environment_snapshot.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_basis.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_cache.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_result.dart';

void main() {
  group('RefreshRecommendCache', () {
    tearDown(RefreshRecommendCache.instance.invalidate);

    test('cacheTtl is 1 hour', () {
      expect(RefreshRecommendCache.cacheTtl, const Duration(hours: 1));
    });

    test('starts empty', () {
      expect(RefreshRecommendCache.instance.result, isNull);
    });

    test('save and read within ttl', () {
      RefreshRecommendCache.instance.save(_sampleResult(signature: 'sig-a'));

      final cached = RefreshRecommendCache.instance.getIfValidFor('sig-a');
      expect(cached, isNotNull);
      expect(cached!.message, contains('추천'));
    });

    test('signature mismatch returns null', () {
      RefreshRecommendCache.instance.save(_sampleResult(signature: 'sig-a'));

      expect(RefreshRecommendCache.instance.getIfValidFor('sig-b'), isNull);
    });

    test('invalidate clears cache', () {
      RefreshRecommendCache.instance.save(_sampleResult(signature: 'sig-a'));
      RefreshRecommendCache.instance.invalidate();

      expect(RefreshRecommendCache.instance.result, isNull);
    });
  });
}

RefreshRecommendResult _sampleResult({required String signature}) {
  return RefreshRecommendResult(
    mode: const RefreshMode(
      id: 'mode-1',
      name: '테스트',
      description: 'desc',
      category: RefreshModeTabs.afterOuting,
      durationSeconds: 300,
      icon: Icons.bolt_outlined,
      odorYn: true,
      dustYn: true,
    ),
    message: '오늘 날씨가 쾌적한 날이니,\n테스트 리프레시 모드를 추천해요.',
    basis: RefreshRecommendBasis.weatherOnly,
    environment: const EnvironmentSnapshot(
      temperatureCelsius: 22,
      humidityPercent: 50,
      isRaining: false,
      isSnowing: false,
    ),
    resolvedAt: DateTime(2026, 6, 15),
    signature: signature,
  );
}
