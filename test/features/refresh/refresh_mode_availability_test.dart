import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/refresh/data/model/refresh_mode.dart';
import 'package:lg_hair_refresher/features/refresh/data/refresh_mode_availability.dart';
import 'package:lg_hair_refresher/shared/models/scent_cartridge_status.dart';

void main() {
  group('RefreshModeAvailability', () {
    const scentMode = RefreshMode(
      id: 'scent',
      name: '향기 케어',
      description: '향기',
      category: '외출 전',
      durationSeconds: 120,
      icon: Icons.spa_outlined,
      scentYn: true,
    );

    const dustMode = RefreshMode(
      id: 'dust',
      name: '먼지 제거',
      description: '먼지',
      category: '외출 전',
      durationSeconds: 120,
      icon: Icons.air_outlined,
      dustYn: true,
    );

    test('allows non-scent modes without cartridge', () {
      expect(
        RefreshModeAvailability.isEnabled(
          dustMode,
          ScentCartridgeStatus.notAttached,
        ),
        isTrue,
      );
    });

    test('blocks scent modes when cartridge is missing', () {
      expect(
        RefreshModeAvailability.isEnabled(
          scentMode,
          ScentCartridgeStatus.notAttached,
        ),
        isFalse,
      );
    });

    test('allows scent modes when cartridge is attached', () {
      expect(
        RefreshModeAvailability.isEnabled(
          scentMode,
          const ScentCartridgeStatus(isAttached: true, remainingPercent: 50),
        ),
        isTrue,
      );
    });

    test('orderSelectableFirst puts enabled modes before scent-only modes', () {
      const comboMode = RefreshMode(
        id: 'combo',
        name: '복합',
        description: '복합',
        category: '외출 전',
        durationSeconds: 180,
        icon: Icons.bolt_outlined,
        dustYn: true,
        scentYn: true,
      );

      final ordered = RefreshModeAvailability.orderSelectableFirst(
        modes: [scentMode, comboMode, dustMode],
        cartridge: ScentCartridgeStatus.notAttached,
      );

      expect(ordered.map((mode) => mode.id), ['dust', 'scent', 'combo']);
    });

    test('orderSelectableFirst keeps order when cartridge is attached', () {
      const modes = [scentMode, dustMode];
      final attached = const ScentCartridgeStatus(
        isAttached: true,
        remainingPercent: 80,
      );

      expect(
        RefreshModeAvailability.orderSelectableFirst(
          modes: modes,
          cartridge: attached,
        ),
        modes,
      );
    });
  });
}
