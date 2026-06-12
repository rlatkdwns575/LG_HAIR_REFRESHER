import 'package:flutter/services.dart';

/// 이메일·비밀번호 입력 검증.
class AuthCredentialsValidator {
  const AuthCredentialsValidator._();

  static final RegExp _koreanCharacters = RegExp(
    r'[\u1100-\u11FF\u3130-\u318F\uA960-\uA97F\uAC00-\uD7A3\uD7B0-\uD7FF]',
  );

  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final TextInputFormatter denyKoreanInputFormatter =
      FilteringTextInputFormatter.deny(_koreanCharacters);

  static bool containsKorean(String value) => _koreanCharacters.hasMatch(value);

  static bool isValidEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || containsKorean(trimmed)) {
      return false;
    }
    return _emailPattern.hasMatch(trimmed);
  }

  static bool isValidPassword(String value) {
    final trimmed = value.trim();
    return trimmed.isNotEmpty && !containsKorean(trimmed);
  }

  static bool isLoginFormValid({
    required String email,
    required String password,
  }) {
    return isValidEmail(email) && isValidPassword(password);
  }

  static String? emailValidationMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '이메일을 입력해 주세요.';
    }
    if (containsKorean(trimmed)) {
      return '이메일에는 한글을 사용할 수 없습니다.';
    }
    if (!isValidEmail(trimmed)) {
      return '올바른 이메일 형식을 입력해 주세요.';
    }
    return null;
  }

  static String? passwordValidationMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (containsKorean(trimmed)) {
      return '비밀번호에는 한글을 사용할 수 없습니다.';
    }
    return null;
  }
}
