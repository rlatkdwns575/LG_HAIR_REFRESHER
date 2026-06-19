import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/routine.dart';

/// 추천 알림(루틴)을 기기 로컬에 JSON으로 저장합니다.
class RoutineLocalStore {
  const RoutineLocalStore();

  static const _storageKey = 'refresh_recommend_alarms_v1';

  Future<List<Routine>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return [
        for (final item in decoded)
          if (item is Map) Routine.fromJson(Map<String, dynamic>.from(item)),
      ];
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveAll(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode([
      for (final routine in routines) routine.toJson(),
    ]);
    await prefs.setString(_storageKey, encoded);
  }
}
