import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/api/home_shortcut_local_store.dart';
import 'package:lg_hair_refresher/features/home/data/model/home_favorite_mode_snapshot.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const userId = 'user-1';
  const otherUserId = 'user-2';

  final mode = RefreshMode(
    id: 'mode-1',
    name: '외출 전 케어',
    description: '테스트',
    category: RefreshModeTabs.beforeOuting,
    durationSeconds: 180,
    icon: Icons.directions_walk_outlined,
    tags: const ['먼지 일반관리'],
    odorYn: false,
    dustYn: true,
    scentYn: false,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('HomeShortcutLocalStore saves and loads favorite per user', () async {
    const store = HomeShortcutLocalStore();
    final snapshot = HomeFavoriteModeSnapshot.fromRefreshMode(mode);

    await store.save(userId, snapshot);

    final loaded = await store.load(userId);
    expect(loaded?.id, mode.id);
    expect(loaded?.name, mode.name);
    expect(loaded?.toRefreshMode().durationLabel, mode.durationLabel);

    expect(await store.load(otherUserId), isNull);
  });

  test('HomeShortcutLocalStore clear removes only target user data', () async {
    const store = HomeShortcutLocalStore();
    final snapshot = HomeFavoriteModeSnapshot.fromRefreshMode(mode);

    await store.save(userId, snapshot);
    await store.save(otherUserId, snapshot);
    await store.clear(userId);

    expect(await store.load(userId), isNull);
    final otherLoaded = await store.load(otherUserId);
    expect(otherLoaded?.id, mode.id);
  });
}
