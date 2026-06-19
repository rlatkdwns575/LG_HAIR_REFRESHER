/// 모발 유형 선택 옵션 (진단 전 프로필 / AUTH_USERS).
class HairProfileOptions {
  const HairProfileOptions._();

  static const hairTypes = ['직모', '반곱슬', '곱슬', '악성곱슬', '기타'];

  static const genders = ['남성', '여성'];

  static const _legacyHairTypeMap = {'웨이브': '반곱슬', '혼합형': '기타'};

  static bool isValidHairType(String? hairType) {
    return hairType != null && hairTypes.contains(hairType);
  }

  /// 이전 옵션(웨이브·혼합형)으로 저장된 값을 현재 목록에 맞게 변환합니다.
  static String? normalizeHairType(String? hairType) {
    if (hairType == null || hairType.isEmpty) {
      return null;
    }
    if (hairTypes.contains(hairType)) {
      return hairType;
    }
    return _legacyHairTypeMap[hairType];
  }
}
