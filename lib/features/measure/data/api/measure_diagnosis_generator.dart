import 'dart:math';

/// 진단 분석 단계에서 저장할 고오염 샘플 점수를 생성합니다.
class MeasureDiagnosisGenerator {
  const MeasureDiagnosisGenerator._();

  static const _damageOptions = ['Low', 'Medium', 'High'];
  static const _thicknessOptions = ['가는', '중간', '굵은'];
  static const _sebumOptions = ['Low', 'Medium', 'High'];
  static const _smellTypePool = ['음식', '땀', '담배', '화장품', '기타'];

  static MeasureResultInsertPayload generateHighPollution({Random? random}) {
    final rng = random ?? Random();
    final hairOdorScore = 66 + rng.nextInt(20);
    final hairDustScore = 66 + rng.nextInt(20);
    final totalPollutionScore = max(
      hairOdorScore,
      hairDustScore,
    ).clamp(60, 100);
    final smellTypes = List<String>.from(_smellTypePool)..shuffle(rng);
    final smellCount = 1 + rng.nextInt(2);

    return MeasureResultInsertPayload(
      hairOdorScore: hairOdorScore,
      hairDustScore: hairDustScore,
      totalPollutionScore: totalPollutionScore,
      hairDamageScore: _damageOptions[rng.nextInt(_damageOptions.length)],
      hairThickness: _thicknessOptions[rng.nextInt(_thicknessOptions.length)],
      hairSebum: _sebumOptions[rng.nextInt(_sebumOptions.length)],
      smellType: smellTypes.take(smellCount).join(','),
    );
  }
}

/// `MEASURE_RESULTS` INSERT 페이로드.
class MeasureResultInsertPayload {
  const MeasureResultInsertPayload({
    required this.hairOdorScore,
    required this.hairDustScore,
    required this.totalPollutionScore,
    required this.hairDamageScore,
    required this.hairThickness,
    required this.hairSebum,
    required this.smellType,
  });

  final int hairOdorScore;
  final int hairDustScore;
  final int totalPollutionScore;
  final String hairDamageScore;
  final String hairThickness;
  final String hairSebum;
  final String smellType;

  Map<String, dynamic> toJson(String userDeviceId) {
    return {
      'user_device_id': userDeviceId,
      'hair_odor_score': hairOdorScore,
      'hair_dust_score': hairDustScore,
      'total_pollution_score': totalPollutionScore,
      'hair_damage_score': hairDamageScore,
      'hair_thickness': hairThickness,
      'hair_sebum': hairSebum,
      'smell_type': smellType,
    };
  }
}
