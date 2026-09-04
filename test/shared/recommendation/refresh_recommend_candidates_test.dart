import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/shared/recommendation/refresh_recommend_candidates.dart';

void main() {
  final scentMode = RefreshMode(
    id: 'scent-1',
    name: '향기 케어',
    description: '향기',
    category: RefreshModeTabs.weather,
    durationSeconds: 300,
    icon: Icons.spa_outlined,
    scentYn: true,
  );

  final plainMode = RefreshMode(
    id: 'plain-1',
    name: '외출 후',
    description: '외출 후',
    category: RefreshModeTabs.afterOuting,
    durationSeconds: 300,
    icon: Icons.home_outlined,
    odorYn: true,
    dustYn: true,
    scentYn: false,
  );

  test('withoutScent excludes scent_yn true modes', () {
    final filtered = RefreshRecommendCandidates.withoutScent([
      scentMode,
      plainMode,
    ]);

    expect(filtered, hasLength(1));
    expect(filtered.first.id, plainMode.id);
  });

  test('pickDefault prefers non-scent afterOuting odor+dust mode', () {
    final scentAfter = scentMode.copyWith(
      id: 'scent-after',
      category: RefreshModeTabs.afterOuting,
      odorYn: true,
      dustYn: true,
    );

    final picked = RefreshRecommendCandidates.pickDefault([
      scentAfter,
      plainMode,
    ]);

    expect(picked?.id, plainMode.id);
    expect(picked?.scentYn, isFalse);
  });

  test('fallbackWhenEmpty keeps scentYn false', () {
    expect(RefreshRecommendCandidates.fallbackWhenEmpty().scentYn, isFalse);
  });
}
