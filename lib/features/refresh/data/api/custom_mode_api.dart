import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/refresh_mode.dart';
import 'refresh_mode_mapper.dart';

class CustomModeApi {
  const CustomModeApi();

  Future<List<RefreshMode>> fetchForUser(String userId) async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select(RefreshModeMapper.selectColumns)
          .eq('custom_yn', true)
          .eq('user_id', userId)
          .order('display_name');

      return rows
          .map(
            (row) => RefreshModeMapper.fromRefreshModeRow(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();
    } catch (error, stackTrace) {
      debugPrint('CustomModeApi.fetchForUser failed: $error\n$stackTrace');
      return const [];
    }
  }

  Future<RefreshMode> create({
    required String userId,
    required String displayName,
    required String category,
    required int durationMinutes,
    required bool dustYn,
    required bool odorYn,
    required bool scentYn,
    int? dustStrength,
    int? odorStrength,
    int? scentStrength,
    String? description,
  }) async {
    final modeId = _generateUuidV4();
    final payload = <String, dynamic>{
      'mode_id': modeId,
      'user_id': userId,
      'display_name': displayName,
      'category': category,
      'duration_time': durationMinutes * 60,
      'custom_yn': true,
      'odor_yn': odorYn,
      'dust_yn': dustYn,
      'scent_yn': scentYn,
    };

    if (description != null && description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }
    if (odorYn && odorStrength != null) {
      payload['odor_strength'] = odorStrength;
    }
    if (dustYn && dustStrength != null) {
      payload['dust_strength'] = dustStrength;
    }
    if (scentYn && scentStrength != null) {
      payload['scent_strength'] = scentStrength;
    }

    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .insert(payload)
          .select(RefreshModeMapper.selectColumns)
          .single();

      return RefreshModeMapper.fromRefreshModeRow(
        Map<String, dynamic>.from(row),
      );
    } on PostgrestException catch (error) {
      throw CustomModeApiException('커스텀 모드 저장에 실패했습니다. (${error.message})');
    }
  }

  Future<bool> delete({required String userId, required String modeId}) async {
    try {
      await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .delete()
          .eq('user_id', userId)
          .eq('mode_id', modeId)
          .eq('custom_yn', true);
      return true;
    } catch (error, stackTrace) {
      debugPrint('CustomModeApi.delete failed: $error\n$stackTrace');
      return false;
    }
  }

  String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int value) => value.toRadixString(16).padLeft(2, '0');

    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}-'
        '${hex(bytes[4])}${hex(bytes[5])}-'
        '${hex(bytes[6])}${hex(bytes[7])}-'
        '${hex(bytes[8])}${hex(bytes[9])}-'
        '${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}'
        '${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }
}

class CustomModeApiException implements Exception {
  const CustomModeApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
