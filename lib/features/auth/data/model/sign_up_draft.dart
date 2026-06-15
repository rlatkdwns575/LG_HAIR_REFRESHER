/// 회원가입 단계 간 전달용 임시 데이터.
class SignUpDraft {
  const SignUpDraft({
    required this.email,
    required this.password,
    this.nickname,
    this.age,
    this.gender,
  });

  final String email;
  final String password;
  final String? nickname;
  final int? age;
  final String? gender;

  bool get isProfileComplete =>
      nickname != null &&
      nickname!.isNotEmpty &&
      age != null &&
      gender != null &&
      gender!.isNotEmpty;

  bool get isReadyToSubmit => isProfileComplete;

  SignUpDraft copyWith({
    String? email,
    String? password,
    String? nickname,
    int? age,
    String? gender,
  }) {
    return SignUpDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }
}
