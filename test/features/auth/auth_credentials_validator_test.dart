import 'package:flutter_test/flutter_test.dart';
import 'package:lg_hair_refresher/features/auth/data/auth_credentials_validator.dart';

void main() {
  group('AuthCredentialsValidator', () {
    test('detects Korean characters', () {
      expect(AuthCredentialsValidator.containsKorean('test'), isFalse);
      expect(AuthCredentialsValidator.containsKorean('한글'), isTrue);
      expect(AuthCredentialsValidator.containsKorean('user@한글.com'), isTrue);
    });

    test('validates email format', () {
      expect(AuthCredentialsValidator.isValidEmail('user@example.com'), isTrue);
      expect(
        AuthCredentialsValidator.isValidEmail('user.name+tag@mail.co.kr'),
        isTrue,
      );
      expect(AuthCredentialsValidator.isValidEmail('invalid-email'), isFalse);
      expect(AuthCredentialsValidator.isValidEmail('user@domain'), isFalse);
      expect(AuthCredentialsValidator.isValidEmail('한글@example.com'), isFalse);
    });

    test('validates password without Korean', () {
      expect(AuthCredentialsValidator.isValidPassword('password123'), isTrue);
      expect(AuthCredentialsValidator.isValidPassword(''), isFalse);
      expect(AuthCredentialsValidator.isValidPassword('비밀번호'), isFalse);
    });

    test('validates login form together', () {
      expect(
        AuthCredentialsValidator.isLoginFormValid(
          email: 'user@example.com',
          password: 'password123',
        ),
        isTrue,
      );
      expect(
        AuthCredentialsValidator.isLoginFormValid(
          email: 'invalid',
          password: 'password123',
        ),
        isFalse,
      );
      expect(
        AuthCredentialsValidator.isLoginFormValid(
          email: 'user@example.com',
          password: '비번',
        ),
        isFalse,
      );
    });

    test('returns validation messages', () {
      expect(
        AuthCredentialsValidator.emailValidationMessage(''),
        '이메일을 입력해 주세요.',
      );
      expect(
        AuthCredentialsValidator.emailValidationMessage('abc'),
        '올바른 이메일 형식을 입력해 주세요.',
      );
      expect(
        AuthCredentialsValidator.emailValidationMessage('한글@mail.com'),
        '이메일에는 한글을 사용할 수 없습니다.',
      );
      expect(
        AuthCredentialsValidator.passwordValidationMessage('비밀번호'),
        '비밀번호에는 한글을 사용할 수 없습니다.',
      );
    });
  });
}
