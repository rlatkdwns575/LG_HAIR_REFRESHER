import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/constants/hair_profile_options.dart';

void main() {
  group('HairProfileOptions', () {
    test('hairTypes는 Figma 1열 5행 옵션을 따른다', () {
      expect(HairProfileOptions.hairTypes, ['직모', '반곱슬', '곱슬', '악성곱슬', '기타']);
    });

    test('normalizeHairType maps legacy values', () {
      expect(HairProfileOptions.normalizeHairType('웨이브'), '반곱슬');
      expect(HairProfileOptions.normalizeHairType('혼합형'), '기타');
      expect(HairProfileOptions.normalizeHairType('직모'), '직모');
      expect(HairProfileOptions.normalizeHairType('알 수 없음'), isNull);
    });
  });
}
