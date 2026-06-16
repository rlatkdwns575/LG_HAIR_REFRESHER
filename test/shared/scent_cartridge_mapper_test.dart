import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/shared/models/scent_cartridge_status.dart';
import 'package:lg_hair_refresher/shared/models/scent_category.dart';
import 'package:lg_hair_refresher/shared/utils/scent_cartridge_mapper.dart';

void main() {
  group('ScentCartridgeMapper', () {
    test('parseFromConsumable handles attached and detached states', () {
      expect(
        ScentCartridgeMapper.parseFromConsumable(null),
        ScentCartridgeStatus.notAttached,
      );
      expect(
        ScentCartridgeMapper.parseFromConsumable({
          'battery_remaining_percent': 60,
        }),
        ScentCartridgeStatus.notAttached,
      );
      expect(
        ScentCartridgeMapper.parseFromConsumable({
          'scent_cartridge_attached': false,
          'scent_cartridge_remaining_percent': 50,
        }),
        ScentCartridgeStatus.notAttached,
      );

      final attached = ScentCartridgeMapper.parseFromConsumable({
        'scent_cartridge_attached': true,
        'scent_cartridge_remaining_percent': 45,
      });
      expect(attached.isAttached, isTrue);
      expect(attached.remainingPercent, 45);

      final percentOnly = ScentCartridgeMapper.parseFromConsumable({
        'scent_cartridge_remaining_percent': 65,
      });
      expect(percentOnly.isAttached, isTrue);
      expect(percentOnly.remainingPercent, 65);
    });

    test('parseFromConsumable reads scent_category when attached', () {
      final withCategory = ScentCartridgeMapper.parseFromConsumable({
        'scent_cartridge_attached': true,
        'scent_cartridge_remaining_percent': 65,
        'scent_category': 'floral',
      });
      expect(withCategory.isAttached, isTrue);
      expect(withCategory.remainingPercent, 65);
      expect(withCategory.categoryLabel, '플로럴');

      final withKoreanCategory = ScentCartridgeMapper.parseFromConsumable({
        'scent_cartridge_attached': true,
        'scent_cartridge_remaining_percent': 60,
        'scent_category': '코튼',
      });
      expect(withKoreanCategory.category, ScentCategory.cotton);
      expect(withKoreanCategory.categoryLabel, '코튼');

      final detached = ScentCartridgeMapper.parseFromConsumable({
        'scent_cartridge_attached': false,
        'scent_category': 'woody',
      });
      expect(detached.isAttached, isFalse);
      expect(detached.category, isNull);
    });

    test('statusLabel maps percent bands', () {
      expect(ScentCartridgeMapper.statusLabel(5), '교체 예정');
      expect(ScentCartridgeMapper.statusLabel(25), '교체 권장');
      expect(ScentCartridgeMapper.statusLabel(50), '보통');
      expect(ScentCartridgeMapper.statusLabel(90), '좋음');
    });
  });
}
