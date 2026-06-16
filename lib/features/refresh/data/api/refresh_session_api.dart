import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../measure/data/api/measure_api.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/refresh_mode.dart';
import '../model/refresh_session_outcome.dart';
import 'refresh_session_result_generator.dart';

/// `REFRESH_SESSIONS` 저장.
class RefreshSessionApi {
  const RefreshSessionApi({this.measureApi = const MeasureApi()});

  final MeasureApi measureApi;

  Future<void> saveCompletedSession({
    required RefreshSessionOutcome outcome,
    required RefreshMode mode,
    String? userId,
  }) async {
    final userDeviceId = await measureApi.fetchUserDeviceId(userId: userId);
    if (userDeviceId == null || userDeviceId.isEmpty) {
      throw const RefreshSessionApiException('연결된 기기가 없어 기록을 저장할 수 없습니다.');
    }

    final durationSeconds = mode.durationSeconds > 0
        ? mode.durationSeconds
        : 180;
    final startedAt = DateTime.now().toUtc().subtract(
      Duration(seconds: durationSeconds),
    );

    final payload = _buildPayload(
      sessionId: _generateUuidV4(),
      userDeviceId: userDeviceId,
      mode: mode,
      outcome: outcome,
      startedAt: startedAt,
      durationSeconds: durationSeconds,
    );

    try {
      await _insertPayload(payload);
      if (kDebugMode) {
        debugPrint(
          'RefreshSessionApi.saveCompletedSession saved session_id='
          '${payload['session_id']}',
        );
      }
    } on PostgrestException catch (error) {
      if (_shouldRetryWithoutMeasureId(error, payload)) {
        payload.remove('measure_id');
        await _insertPayload(payload);
        if (kDebugMode) {
          debugPrint(
            'RefreshSessionApi: saved without measure_id (${error.message})',
          );
        }
        return;
      }
      throw RefreshSessionApiException(
        '리프레시 기록 저장에 실패했습니다. '
        '(${RefreshSessionApiException.fromPostgrest(error)})',
      );
    }
  }

  Future<void> _insertPayload(Map<String, dynamic> payload) async {
    await SupabaseService.client
        .from(SupabaseTables.refreshSessions)
        .insert(payload);
  }

  bool _shouldRetryWithoutMeasureId(
    PostgrestException error,
    Map<String, dynamic> payload,
  ) {
    if (!payload.containsKey('measure_id')) {
      return false;
    }

    if (error.code == '42501' ||
        error.message.toLowerCase().contains('row-level security')) {
      return false;
    }

    final message = error.message.toLowerCase();
    return message.contains('measure_id') || message.contains('foreign key');
  }

  Map<String, dynamic> _buildPayload({
    required String sessionId,
    required String userDeviceId,
    required RefreshMode mode,
    required RefreshSessionOutcome outcome,
    required DateTime startedAt,
    required int durationSeconds,
  }) {
    final scores = outcome.scores;
    final pollutionBefore =
        scores.pollutionBefore ??
        RefreshSessionResultGenerator.computePollutionScore(
          odor: scores.odorBefore,
          dust: scores.dustBefore,
        );
    final pollutionAfter =
        scores.pollutionAfter ??
        RefreshSessionResultGenerator.computePollutionScore(
          odor: scores.odorAfter,
          dust: scores.dustAfter,
          fallback: pollutionBefore,
        );

    return {
      'session_id': sessionId,
      'user_device_id': userDeviceId,
      'mode_id': mode.id,
      if (outcome.measureId != null && outcome.measureId!.isNotEmpty)
        'measure_id': outcome.measureId,
      'started_at': startedAt.toIso8601String(),
      'duration_time': durationSeconds,
      'pollution_score_before': pollutionBefore,
      'pollution_score_after': pollutionAfter,
      if (mode.odorYn && scores.odorBefore != null)
        'odor_score_before': scores.odorBefore,
      if (mode.odorYn && scores.odorAfter != null)
        'odor_score_after': scores.odorAfter,
      if (mode.dustYn && scores.dustBefore != null)
        'dust_score_before': scores.dustBefore,
      if (mode.dustYn && scores.dustAfter != null)
        'dust_score_after': scores.dustAfter,
    };
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

class RefreshSessionApiException implements Exception {
  const RefreshSessionApiException(this.message);

  final String message;

  static const permissionDeniedHint =
      'Supabase SQL Editor에서 supabase/dev_read_policies.sql을 실행해주세요.';

  static String fromPostgrest(PostgrestException error) {
    final message = error.message;
    if (message.contains('permission denied') ||
        error.code == '42501' ||
        message.contains('row-level security')) {
      return 'REFRESH_SESSIONS 테이블 권한이 없습니다. $permissionDeniedHint';
    }
    return message;
  }

  @override
  String toString() => message;
}
