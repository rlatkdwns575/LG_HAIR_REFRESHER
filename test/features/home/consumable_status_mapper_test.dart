import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/api/consumable_status_mapper.dart';

void main() {
  group('ConsumableStatusMapper.filterStatusLabel', () {
    test('returns 양호 at 70 percent or above', () {
      expect(ConsumableStatusMapper.filterStatusLabel(70), '양호');
      expect(ConsumableStatusMapper.filterStatusLabel(100), '양호');
    });

    test('returns 교체 예정 between 30 and 69 percent', () {
      expect(ConsumableStatusMapper.filterStatusLabel(69), '교체 예정');
      expect(ConsumableStatusMapper.filterStatusLabel(30), '교체 예정');
    });

    test('returns 교체 필요 below 30 percent', () {
      expect(ConsumableStatusMapper.filterStatusLabel(29), '교체 필요');
      expect(ConsumableStatusMapper.filterStatusLabel(0), '교체 필요');
    });
  });
}
