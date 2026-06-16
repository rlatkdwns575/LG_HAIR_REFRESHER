/// 설정 화면 프로필 요약.
class SettingsUserSummary {
  const SettingsUserSummary({
    required this.nickname,
    required this.email,
    this.age,
    this.gender,
    this.hairType,
  });

  final String nickname;
  final String email;
  final int? age;
  final String? gender;
  final String? hairType;

  String get profileLine {
    final parts = <String>[];
    if (age != null && age! > 0) {
      parts.add('$age세');
    }
    if (gender != null && gender!.isNotEmpty) {
      parts.add(gender!);
    }
    if (hairType != null && hairType!.isNotEmpty) {
      parts.add(hairType!);
    }
    if (parts.isEmpty) {
      return email;
    }
    return parts.join(' · ');
  }

  static const guest = SettingsUserSummary(nickname: '게스트', email: '로그인 정보 없음');
}
