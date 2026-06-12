import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/home/data/api/consumable_status_mapper.dart';
import 'package:lg_hair_refresher/features/home/data/model/home_filter_status.dart';

void main() {
  group('ConsumableStatusMapper.filterStatus', () {
    test('returns replaceSoon at 10 percent or below', () {
      expect(
        ConsumableStatusMapper.filterStatus(10),
        const HomeFilterStatus(
          tier: HomeFilterStatusTier.replaceSoon,
          label: '교체 예정',
        ),
      );
      expect(
        ConsumableStatusMapper.filterStatus(0),
        const HomeFilterStatus(
          tier: HomeFilterStatusTier.replaceSoon,
          label: '교체 예정',
        ),
      );
    });

    test('returns replaceRecommended between 11 and 30 percent', () {
      expect(
        ConsumableStatusMapper.filterStatus(11),
        const HomeFilterStatus(
          tier: HomeFilterStatusTier.replaceRecommended,
          label: '교체 권장',
        ),
      );
      expect(
        ConsumableStatusMapper.filterStatus(30),
        const HomeFilterStatus(
          tier: HomeFilterStatusTier.replaceRecommended,
          label: '교체 권장',
        ),
      );
    });

    test('returns normal between 31 and 70 percent', () {
      expect(
        ConsumableStatusMapper.filterStatus(31),
        const HomeFilterStatus(tier: HomeFilterStatusTier.normal, label: '보통'),
      );
      expect(
        ConsumableStatusMapper.filterStatus(70),
        const HomeFilterStatus(tier: HomeFilterStatusTier.normal, label: '보통'),
      );
    });

    test('returns fresh at 71 percent or above', () {
      expect(
        ConsumableStatusMapper.filterStatus(71),
        const HomeFilterStatus(tier: HomeFilterStatusTier.fresh, label: '새거'),
      );
      expect(
        ConsumableStatusMapper.filterStatus(100),
        const HomeFilterStatus(tier: HomeFilterStatusTier.fresh, label: '새거'),
      );
    });

    test('clamps values above 100', () {
      expect(
        ConsumableStatusMapper.filterStatus(150).tier,
        HomeFilterStatusTier.fresh,
      );
    });
  });

  group('ConsumableStatusMapper.filterStatusLabel', () {
    test('returns label from filterStatus', () {
      expect(ConsumableStatusMapper.filterStatusLabel(10), '교체 예정');
      expect(ConsumableStatusMapper.filterStatusLabel(25), '교체 권장');
      expect(ConsumableStatusMapper.filterStatusLabel(50), '보통');
      expect(ConsumableStatusMapper.filterStatusLabel(90), '새거');
    });
  });
}
