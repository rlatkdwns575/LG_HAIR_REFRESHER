import 'package:flutter/material.dart';

import '../care_duration_split.dart';

/// 리프레시 칩 탭 라벨.
class RefreshModeTabs {
  const RefreshModeTabs._();

  static const allTab = '전체';

  static const all = [allTab, '커스텀 모드', '외출 전', '외출 후', '날씨'];

  static const customMode = '커스텀 모드';
  static const beforeOuting = '외출 전';
  static const afterOuting = '외출 후';
  static const weather = '날씨';
  static const etc = '기타';

  /// 커스텀 모드 생성 시 선택 가능한 카테고리.
  static const customSelectableCategories = [
    beforeOuting,
    afterOuting,
    weather,
    etc,
  ];
}

/// 리프레시 모드 화면 데이터 모델.
class RefreshMode {
  const RefreshMode({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.durationSeconds,
    required this.icon,
    this.tags = const [],
    this.isCustom = false,
    this.createdByUser = false,
    this.odorYn = false,
    this.dustYn = false,
    this.scentYn = false,
    this.odorStrength,
    this.dustStrength,
    this.scentStrength,
  });

  factory RefreshMode.custom({
    required String id,
    required String name,
    required String description,
    required int durationMinutes,
    List<String> tags = const [],
  }) {
    return RefreshMode(
      id: id,
      name: name,
      description: description,
      category: RefreshModeTabs.customMode,
      durationSeconds: durationMinutes * 60,
      icon: Icons.tune_outlined,
      tags: tags,
      isCustom: true,
      createdByUser: true,
    );
  }

  final String id;
  final String name;
  final String description;
  final String category;
  final int durationSeconds;
  final IconData icon;
  final List<String> tags;
  final bool isCustom;
  final bool createdByUser;
  final bool odorYn;
  final bool dustYn;
  final bool scentYn;
  final int? odorStrength;
  final int? dustStrength;
  final int? scentStrength;

  bool get isDeletable => isCustom || createdByUser;

  String get durationLabel =>
      CareDurationSplit.formatKoreanTime(durationSeconds);

  Map<String, dynamic> toRecommendJson() => {
    'mode_id': id,
    'display_name': name,
    'category': category,
    'duration_seconds': durationSeconds,
    'odor_yn': odorYn,
    'dust_yn': dustYn,
    'scent_yn': scentYn,
    if (odorStrength != null) 'odor_strength': odorStrength,
    if (dustStrength != null) 'dust_strength': dustStrength,
    if (scentStrength != null) 'scent_strength': scentStrength,
  };

  RefreshMode copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    int? durationSeconds,
    IconData? icon,
    List<String>? tags,
    bool? isCustom,
    bool? createdByUser,
    bool? odorYn,
    bool? dustYn,
    bool? scentYn,
    int? odorStrength,
    int? dustStrength,
    int? scentStrength,
  }) {
    return RefreshMode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      isCustom: isCustom ?? this.isCustom,
      createdByUser: createdByUser ?? this.createdByUser,
      odorYn: odorYn ?? this.odorYn,
      dustYn: dustYn ?? this.dustYn,
      scentYn: scentYn ?? this.scentYn,
      odorStrength: odorStrength ?? this.odorStrength,
      dustStrength: dustStrength ?? this.dustStrength,
      scentStrength: scentStrength ?? this.scentStrength,
    );
  }
}
