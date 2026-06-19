import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/routine.dart';
import 'routine_local_store.dart';

/// 추천 알림 CRUD — 루틴 데이터는 [RoutineLocalStore], 모드 목록만 Supabase.
class RoutineApi {
  const RoutineApi({RoutineLocalStore? localStore})
    : _localStore = localStore ?? const RoutineLocalStore();

  final RoutineLocalStore _localStore;

  Future<List<Routine>> fetchAll() async {
    final routines = await _localStore.loadAll();
    routines.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return routines;
  }

  /// 모드 선택 드롭다운용 프리셋 모드 목록(`REFRESH_MODE`).
  Future<List<RoutineModeOption>> fetchModeOptions() async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select('mode_id, display_name')
          .eq('custom_yn', false)
          .order('display_name');

      return [
        for (final row in rows)
          if (row['mode_id'] is String)
            RoutineModeOption(
              id: row['mode_id'] as String,
              name: (row['display_name'] as String?) ?? '이름 없는 모드',
            ),
      ];
    } catch (error, stackTrace) {
      debugPrint('RoutineApi.fetchModeOptions failed: $error\n$stackTrace');
      return const [];
    }
  }

  Future<Routine> create(Routine routine) async {
    if (routine.modeId == null) {
      throw const RoutineApiException('리프레시 모드를 선택해주세요.');
    }

    final now = DateTime.now().toUtc();
    final toSave = routine.copyWith(
      id: _newId(),
      createdAt: now,
      updatedAt: now,
    );

    final routines = await _localStore.loadAll();
    await _localStore.saveAll([toSave, ...routines]);
    return toSave;
  }

  Future<Routine> update(Routine routine) async {
    final id = routine.id;
    if (id == null) {
      throw const RoutineApiException('수정할 루틴 정보가 없어요.');
    }

    final now = DateTime.now().toUtc();
    final toSave = routine.copyWith(
      updatedAt: now,
      createdAt: routine.createdAt ?? now,
    );

    final routines = await _localStore.loadAll();
    var found = false;
    final next = routines.map((item) {
      if (item.id == id) {
        found = true;
        return toSave;
      }
      return item;
    }).toList();
    if (!found) {
      throw const RoutineApiException('수정할 루틴을 찾지 못했어요.');
    }

    await _localStore.saveAll(next);
    return toSave;
  }

  Future<void> delete(String id) async {
    final routines = await _localStore.loadAll();
    final next = routines.where((routine) => routine.id != id).toList();
    if (next.length == routines.length) {
      throw const RoutineApiException('삭제할 루틴을 찾지 못했어요.');
    }
    await _localStore.saveAll(next);
  }

  static String _newId() {
    final random = Random();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final chars = bytes.map(hex).join();
    return '${chars.substring(0, 8)}-${chars.substring(8, 12)}-'
        '${chars.substring(12, 16)}-${chars.substring(16, 20)}-'
        '${chars.substring(20, 32)}';
  }
}

class RoutineApiException implements Exception {
  const RoutineApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
