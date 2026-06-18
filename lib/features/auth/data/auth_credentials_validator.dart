import 'package:flutter/services.dart';

/// 회원가입 비밀번호 조건 종류.
enum PasswordRuleId { minLength, combination, noSequential, notSimilarToId }

/// 회원가입 비밀번호 조건별 충족 여부.
class PasswordRuleStatus {
  const PasswordRuleStatus({
    required this.id,
    required this.label,
    required this.satisfied,
  });

  final PasswordRuleId id;
  final String label;
  final bool satisfied;
}

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

  static final RegExp _letterPattern = RegExp(r'[A-Za-z]');
  static final RegExp _digitPattern = RegExp(r'[0-9]');
  static final RegExp _specialPattern = RegExp(r'[^A-Za-z0-9\s]');

  static const passwordRuleLabels = <PasswordRuleId, String>{
    PasswordRuleId.minLength: '최소 8자 이상',
    PasswordRuleId.combination: '영문, 숫자, 특수문자 3가지 조합',
    PasswordRuleId.noSequential: '연속된 문자·숫자 사용 불가',
    PasswordRuleId.notSimilarToId: '아이디와 3자 이상 동일한 문자 사용 불가',
  };

  /// 회원가입 비밀번호 조건별 충족 여부를 평가합니다.
  ///
  /// 비밀번호 입력에 따라 실시간으로 조건 표시를 갱신할 때 사용합니다.
  static List<PasswordRuleStatus> evaluateSignUpPassword(
    String password, {
    required String email,
  }) {
    final hasInput = password.isNotEmpty;
    return [
      PasswordRuleStatus(
        id: PasswordRuleId.minLength,
        label: passwordRuleLabels[PasswordRuleId.minLength]!,
        satisfied: password.length >= 8,
      ),
      PasswordRuleStatus(
        id: PasswordRuleId.combination,
        label: passwordRuleLabels[PasswordRuleId.combination]!,
        satisfied: _hasCombination(password),
      ),
      PasswordRuleStatus(
        id: PasswordRuleId.noSequential,
        label: passwordRuleLabels[PasswordRuleId.noSequential]!,
        satisfied: hasInput && _hasNoSequential(password),
      ),
      PasswordRuleStatus(
        id: PasswordRuleId.notSimilarToId,
        label: passwordRuleLabels[PasswordRuleId.notSimilarToId]!,
        satisfied: hasInput && _isNotSimilarToId(password, email),
      ),
    ];
  }

  static bool _hasCombination(String password) {
    return _letterPattern.hasMatch(password) &&
        _digitPattern.hasMatch(password) &&
        _specialPattern.hasMatch(password);
  }

  static bool _hasNoSequential(String password) {
    if (password.length < 3) {
      return true;
    }
    for (var i = 0; i + 2 < password.length; i++) {
      final a = password.codeUnitAt(i);
      final b = password.codeUnitAt(i + 1);
      final c = password.codeUnitAt(i + 2);

      if (a == b && b == c) {
        return false;
      }

      final allSequenceChars =
          _isSequenceChar(a) && _isSequenceChar(b) && _isSequenceChar(c);
      if (!allSequenceChars) {
        continue;
      }
      final ascending = b - a == 1 && c - b == 1;
      final descending = a - b == 1 && b - c == 1;
      if (ascending || descending) {
        return false;
      }
    }
    return true;
  }

  /// 숫자(0–9), 영문 대/소문자만 연속 판정 대상으로 봅니다.
  static bool _isSequenceChar(int code) {
    return (code >= 48 && code <= 57) ||
        (code >= 65 && code <= 90) ||
        (code >= 97 && code <= 122);
  }

  static bool _isNotSimilarToId(String password, String email) {
    final id = _idFromEmail(email);
    if (id.length < 3) {
      return true;
    }
    final lowerPassword = password.toLowerCase();
    for (var i = 0; i + 3 <= id.length; i++) {
      final segment = id.substring(i, i + 3);
      if (lowerPassword.contains(segment)) {
        return false;
      }
    }
    return true;
  }

  static String _idFromEmail(String email) {
    final normalized = email.trim().toLowerCase();
    final atIndex = normalized.indexOf('@');
    return atIndex >= 0 ? normalized.substring(0, atIndex) : normalized;
  }

  /// 회원가입 비밀번호가 모든 조건을 만족하는지 여부.
  static bool isSignUpPasswordValid(String password, {required String email}) {
    if (containsKorean(password)) {
      return false;
    }
    return evaluateSignUpPassword(
      password,
      email: email,
    ).every((status) => status.satisfied);
  }

  static bool isSignUpFormValid({
    required String email,
    required String password,
  }) {
    return isValidEmail(email) && isSignUpPasswordValid(password, email: email);
  }

  static String? signUpPasswordValidationMessage(
    String password, {
    required String email,
  }) {
    if (password.trim().isEmpty) {
      return '비밀번호를 입력해 주세요.';
    }
    if (containsKorean(password)) {
      return '비밀번호에는 한글을 사용할 수 없습니다.';
    }
    final unmet = evaluateSignUpPassword(
      password,
      email: email,
    ).where((status) => !status.satisfied);
    if (unmet.isNotEmpty) {
      return '비밀번호 조건을 모두 만족해 주세요.';
    }
    return null;
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

  /// 회원가입 비밀번호 조건 안내.
  static const passwordRulesDescription =
      '• 최소 8자 이상\n'
      '• 영문, 숫자, 특수문자 3가지 조합\n'
      '• 연속된 문자·숫자 사용 불가\n'
      '• 아이디와 3자 이상 동일한 문자 사용 불가';
}
