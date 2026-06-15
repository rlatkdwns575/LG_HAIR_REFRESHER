/// `MEASURE_RESULTS` 테이블 행 모델.
class MeasureResultRecord {
  const MeasureResultRecord({
    required this.measureId,
    required this.userDeviceId,
    required this.createdAt,
    required this.hairDustScore,
    required this.hairOdorScore,
    required this.totalPollutionScore,
    this.hairDamageScore,
    this.hairThickness,
    this.hairSebum,
    this.smellType,
  });

  final String measureId;
  final String userDeviceId;
  final DateTime createdAt;
  final int hairDustScore;
  final int hairOdorScore;
  final int totalPollutionScore;
  final String? hairDamageScore;
  final String? hairThickness;
  final String? hairSebum;
  final String? smellType;

  factory MeasureResultRecord.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'];
    final createdAt = createdAtRaw is String
        ? DateTime.parse(createdAtRaw)
        : DateTime.fromMillisecondsSinceEpoch(0);

    return MeasureResultRecord(
      measureId: json['measure_id'] as String? ?? '',
      userDeviceId: json['user_device_id'] as String? ?? '',
      createdAt: createdAt,
      hairDustScore: _readInt(json['hair_dust_score']) ?? 0,
      hairOdorScore: _readInt(json['hair_odor_score']) ?? 0,
      totalPollutionScore: _readInt(json['total_pollution_score']) ?? 0,
      hairDamageScore: _readText(json['hair_damage_score']),
      hairThickness: _readText(json['hair_thickness']),
      hairSebum: _readText(json['hair_sebum']),
      smellType: _readText(json['smell_type']),
    );
  }

  static int? _readInt(Object? value) {
    if (value is num) {
      return value.round();
    }
    return null;
  }

  static String? _readText(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
