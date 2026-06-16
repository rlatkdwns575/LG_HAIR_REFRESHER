import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/shared/models/scent_category.dart';

void main() {
  group('ScentCategory', () {
    test('fromDbValue maps DB values to enum', () {
      expect(ScentCategory.fromDbValue('cotton'), ScentCategory.cotton);
      expect(ScentCategory.fromDbValue('FLORAL'), ScentCategory.floral);
      expect(ScentCategory.fromDbValue(' citrus '), ScentCategory.citrus);
      expect(ScentCategory.fromDbValue('코튼'), ScentCategory.cotton);
      expect(ScentCategory.fromDbValue('플로럴'), ScentCategory.floral);
      expect(ScentCategory.fromDbValue('woody'), ScentCategory.woody);
      expect(ScentCategory.fromDbValue('musk'), ScentCategory.musk);
      expect(ScentCategory.fromDbValue('fruity'), ScentCategory.fruity);
      expect(ScentCategory.fromDbValue('unknown'), isNull);
      expect(ScentCategory.fromDbValue(null), isNull);
    });

    test('displayLabel returns Korean label for stored values', () {
      expect(ScentCategory.displayLabel('floral'), '플로럴');
      expect(ScentCategory.displayLabel('코튼'), '코튼');
      expect(ScentCategory.displayLabel('custom'), 'custom');
    });

    test('labels match product copy', () {
      expect(ScentCategory.allLabels, '코튼, 플로럴, 시트러스, 우디, 머스크, 프루티');
    });
  });
}
