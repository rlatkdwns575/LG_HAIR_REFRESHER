import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/settings/data/api/settings_device_mapper.dart';

void main() {
  group('SettingsDeviceMapper', () {
    test('filterStatusLabel maps percent bands', () {
      expect(SettingsDeviceMapper.filterStatusLabel(5), '교체 예정');
      expect(SettingsDeviceMapper.filterStatusLabel(25), '교체 권장');
      expect(SettingsDeviceMapper.filterStatusLabel(50), '보통');
      expect(SettingsDeviceMapper.filterStatusLabel(90), '좋음');
    });

    test('displayModelName normalizes empty and product code', () {
      expect(SettingsDeviceMapper.displayModelName(null), 'LG 퓨리헤어');
      expect(SettingsDeviceMapper.displayModelName(''), 'LG 퓨리헤어');
      expect(
        SettingsDeviceMapper.displayModelName('lghairrefresher'),
        'LG 퓨리헤어',
      );
      expect(
        SettingsDeviceMapper.displayModelName('Custom Model'),
        'Custom Model',
      );
    });

    test('scentCartridgeStatusLabel delegates to shared mapper', () {
      expect(SettingsDeviceMapper.scentCartridgeStatusLabel(5), '교체 예정');
      expect(SettingsDeviceMapper.scentCartridgeStatusLabel(90), '좋음');
    });
  });
}
