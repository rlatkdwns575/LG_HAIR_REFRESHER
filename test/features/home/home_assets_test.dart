import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/home_assets.dart';

void main() {
  test('batteryIconFor returns home asset path', () {
    expect(
      HomeAssets.batteryIconFor(60),
      'assets/images/home/battery/icon_battery_24_state_60.png',
    );
  });
}
