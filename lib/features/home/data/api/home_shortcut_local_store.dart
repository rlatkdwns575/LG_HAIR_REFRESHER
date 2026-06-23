import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/home_favorite_mode_snapshot.dart';

/// 사용자별 홈 즐겨찾기(리프레시 바로가기) 로컬 저장소.
class HomeShortcutLocalStore {
  const HomeShortcutLocalStore();

  static String storageKeyFor(String userId) =>
      'home_favorite_shortcut_v1_$userId';

  Future<HomeFavoriteModeSnapshot?> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKeyFor(userId));
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return null;
      }
      return HomeFavoriteModeSnapshot.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(String userId, HomeFavoriteModeSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKeyFor(userId), jsonEncode(snapshot.toJson()));
  }

  Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKeyFor(userId));
  }
}
