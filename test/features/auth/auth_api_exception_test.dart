import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/auth/data/api/auth_api.dart'
    as app_auth;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AuthApiException.fromAuthException', () {
    test('maps email confirmation error', () {
      expect(
        app_auth.AuthApiException.fromAuthException(
          const AuthException('Email not confirmed'),
        ),
        contains('이메일 인증'),
      );
    });

    test('maps invalid credentials error', () {
      expect(
        app_auth.AuthApiException.fromAuthException(
          const AuthException('Invalid login credentials'),
        ),
        contains('이메일 또는 비밀번호'),
      );
    });
  });
}
