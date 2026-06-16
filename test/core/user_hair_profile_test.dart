import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/core/models/user_hair_profile.dart';

void main() {
  group('UserHairProfile', () {
    test('parses hair type column from json', () {
      final profile = UserHairProfile.fromJson({'hair_type': '웨이브'});

      expect(profile.hairType, '웨이브');
      expect(profile.isComplete, isTrue);
    });

    test('toUpdateJson maps hair_type column', () {
      const profile = UserHairProfile(hairType: '직모');

      expect(profile.toUpdateJson(), {'hair_type': '직모'});
    });

    test('isComplete is false when hair type is missing', () {
      const profile = UserHairProfile();

      expect(profile.isComplete, isFalse);
    });
  });
}
