/// 회원가입 단계 간 전달용 임시 데이터.
class SignUpDraft {
  const SignUpDraft({
    required this.email,
    required this.password,
    this.nickname,
    this.age,
    this.gender,
    this.hairLength,
    this.hairType,
  });

  final String email;
  final String password;
  final String? nickname;
  final int? age;
  final String? gender;
  final String? hairLength;
  final String? hairType;

  bool get isProfileComplete =>
      nickname != null &&
      nickname!.isNotEmpty &&
      age != null &&
      gender != null &&
      gender!.isNotEmpty;

  bool get isHairProfileComplete =>
      hairLength != null &&
      hairLength!.isNotEmpty &&
      hairType != null &&
      hairType!.isNotEmpty;

  bool get isReadyToSubmit => isProfileComplete && isHairProfileComplete;

  SignUpDraft copyWith({
    String? email,
    String? password,
    String? nickname,
    int? age,
    String? gender,
    String? hairLength,
    String? hairType,
  }) {
    return SignUpDraft(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      hairLength: hairLength ?? this.hairLength,
      hairType: hairType ?? this.hairType,
    );
  }
}
