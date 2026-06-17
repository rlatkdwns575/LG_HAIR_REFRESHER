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
          .select(RefreshModeMapper.selectColumns)
          .eq('custom_yn', false)
          .order('display_name');

      return rows
          .map(
            (row) => RefreshModeMapper.fromRefreshModeRow(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// 향기 케어 프리셋 모드를 조회합니다.
  Future<RefreshMode?> fetchScentCarePreset() async {
    try {
      final rows = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select(RefreshModeMapper.selectColumns)
          .eq('custom_yn', false)
          .eq('scent_yn', true)
          .order('display_name');

      final modes = rows
          .map(
            (row) => RefreshModeMapper.fromRefreshModeRow(
              Map<String, dynamic>.from(row),
            ),
          )
          .toList();

      for (final mode in modes) {
        if (mode.isScentOnlyCare) {
          return mode;
        }
      }

      for (final mode in modes) {
        if (mode.name.contains('향기')) {
          return mode;
        }
      }

      return modes.isEmpty ? null : modes.first;
    } catch (_) {
      return null;
    }
  }

  Future<RefreshMode?> fetchModeById(String modeId) async {
    try {
      final row = await SupabaseService.client
          .from(SupabaseTables.refreshMode)
          .select(RefreshModeMapper.selectColumns)
          .eq('mode_id', modeId)
          .maybeSingle();

      if (row == null) {
        return null;
      }

      return RefreshModeMapper.fromRefreshModeRow(
        Map<String, dynamic>.from(row),
      );
    } catch (_) {
      return null;
    }
  }
}
