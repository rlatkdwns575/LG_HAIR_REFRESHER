import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/home_recommend_cache.dart';

void main() {
  group('HomeRecommendCache', () {
    tearDown(HomeRecommendCache.instance.clear);

    test('cache ttl is one hour', () {
      expect(HomeRecommendCache.cacheTtl, const Duration(hours: 1));
    });

    test('returns null when cache is empty', () {
      expect(HomeRecommendCache.instance.message, isNull);
      expect(HomeRecommendCache.instance.hasValidCache, isFalse);
    });

    test('returns saved message while within ttl', () {
      HomeRecommendCache.instance.save('오늘 날씨가 쾌적한 날이니,\n테스트 모드를 추천해요.');

      expect(HomeRecommendCache.instance.hasValidCache, isTrue);
      expect(
        HomeRecommendCache.instance.message,
        '오늘 날씨가 쾌적한 날이니,\n테스트 모드를 추천해요.',
      );
    });

    test('ignores empty message', () {
      HomeRecommendCache.instance.save('   ');

      expect(HomeRecommendCache.instance.hasValidCache, isFalse);
    });

    test('clear removes cached message', () {
      HomeRecommendCache.instance.save('캐시된 문구');
      HomeRecommendCache.instance.clear();

      expect(HomeRecommendCache.instance.message, isNull);
    });
  });
}
