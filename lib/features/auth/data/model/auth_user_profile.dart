/// `AUTH_USERS` 테이블 프로필 데이터.
class AuthUserProfile {
  const AuthUserProfile({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.age,
    required this.gender,
    required this.hairLength,
    required this.hairType,
  });

  factory AuthUserProfile.fromJson(Map<String, dynamic> json) {
    return AuthUserProfile(
      userId: json['user_id'] as String,
      email: json['email'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      age: (json['age'] as num?)?.round() ?? 0,
      gender: json['gender'] as String? ?? '',
      hairLength: json['hair_length'] as String? ?? '',
      hairType: json['hair_type'] as String? ?? '',
    );
  }

  final String userId;
  final String email;
  final String nickname;
  final int age;
  final String gender;
  final String hairLength;
  final String hairType;

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'email': email,
    'nickname': nickname,
    'age': age,
    'gender': gender,
    'hair_length': hairLength,
    'hair_type': hairType,
  };
}
