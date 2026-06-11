import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/api/refresh_mode_mapper.dart';

void main() {
  group('RefreshModeMapper.fromRefreshModeRow', () {
    test('maps DB row to RefreshMode with tags and description', () {
      final mode = RefreshModeMapper.fromRefreshModeRow({
        'mode_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'display_name': '외출 전 케어',
        'category': '외출 전',
        'duration_time': 150,
        'odor_yn': true,
        'dust_yn': true,
        'scent_yn': false,
        'odor_strength': 3,
        'dust_strength': 2,
        'scent_strength': null,
      });

      expect(mode.id, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
      expect(mode.name, '외출 전 케어');
      expect(mode.category, '외출 전');
      expect(mode.durationSeconds, 150);
      expect(mode.durationLabel, '2분 30초');
      expect(mode.odorYn, isTrue);
      expect(mode.dustYn, isTrue);
      expect(mode.scentYn, isFalse);
      expect(mode.odorStrength, 3);
      expect(mode.dustStrength, 2);
      expect(mode.icon, Icons.directions_walk_outlined);
      expect(mode.description, contains('먼지'));
      expect(mode.description, contains('냄새'));
      expect(mode.tags, ['먼지 제거 일반관리', '냄새 제거 집중관리']);
    });

    test('uses default category and icon when category is empty', () {
      final mode = RefreshModeMapper.fromRefreshModeRow({
        'mode_id': 'mode-1',
        'display_name': '기본 모드',
        'category': '',
        'duration_time': 90,
        'odor_yn': false,
        'dust_yn': false,
        'scent_yn': true,
        'scent_strength': 1,
      });

      expect(mode.category, '기타');
      expect(mode.icon, Icons.auto_awesome_outlined);
      expect(mode.tags, ['향 케어 간편관리']);
    });
  });

  group('RefreshModeMapper.strengthLabel', () {
    test('maps strength levels to Korean labels', () {
      expect(RefreshModeMapper.strengthLabel(null), '일반관리');
      expect(RefreshModeMapper.strengthLabel(1), '간편관리');
      expect(RefreshModeMapper.strengthLabel(2), '일반관리');
      expect(RefreshModeMapper.strengthLabel(3), '집중관리');
    });
  });
}
