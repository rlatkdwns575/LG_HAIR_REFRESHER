import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/auth/data/model/auth_user_profile.dart';
import 'package:lg_hair_refresher/features/auth/data/model/sign_up_draft.dart';

void main() {
  group('SignUpDraft', () {
    test('isReadyToSubmit is false until hair profile is filled', () {
      const draft = SignUpDraft(
        email: 'user@example.com',
        password: 'password123',
        nickname: '민지',
        age: 24,
        gender: '여성',
      );

      expect(draft.isProfileComplete, isTrue);
      expect(draft.isHairProfileComplete, isFalse);
      expect(draft.isReadyToSubmit, isFalse);
    });

    test('isReadyToSubmit is true with full profile', () {
      const draft = SignUpDraft(
        email: 'user@example.com',
        password: 'password123',
        nickname: '민지',
        age: 24,
        gender: '여성',
        hairLength: '중단발',
        hairType: '웨이브',
      );

      expect(draft.isReadyToSubmit, isTrue);
    });
  });

  group('AuthUserProfile', () {
    test('toInsertJson maps snake_case columns', () {
      const profile = AuthUserProfile(
        userId: '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        email: 'dev.user@example.com',
        nickname: '테스트유저',
        age: 24,
        gender: '여성',
        hairLength: '중단발',
        hairType: '웨이브',
      );

      expect(profile.toInsertJson(), {
        'user_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'email': 'dev.user@example.com',
        'nickname': '테스트유저',
        'age': 24,
        'gender': '여성',
        'hair_length': '중단발',
        'hair_type': '웨이브',
      });
    });
  });
}
