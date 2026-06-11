import 'package:flutter/foundation.dart';

import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/services/supabase_service.dart';
import '../model/refresh_mode.dart';
import 'refresh_mode_mapper.dart';

class RefreshApi {
  const RefreshApi();

  Future<List<RefreshMode>> fetchPresetModes() async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select(
            'mode_id, display_name, category, duration_time, '
            'odor_yn, dust_yn, scent_yn, '
            'odor_strength, dust_strength, scent_strength',
          )
          .order('display_name');

      return rows
          .map(
            (row) => RefreshModeMapper.fromRefreshModeRow(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();
    } catch (error, stackTrace) {
      debugPrint('RefreshApi.fetchPresetModes failed: $error\n$stackTrace');
      return const [];
    }
  }
}
