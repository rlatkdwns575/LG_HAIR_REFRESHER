/// `AUTH_USERS`에 저장되는 모발 유형.
class UserHairProfile {
  const UserHairProfile({this.hairType});

  factory UserHairProfile.fromJson(Map<String, dynamic> json) {
    return UserHairProfile(hairType: _readText(json['hair_type']));
  }

  final String? hairType;

  bool get isComplete => hairType != null && hairType!.isNotEmpty;

  Map<String, dynamic> toUpdateJson() => {'hair_type': hairType};

  static String? _readText(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
