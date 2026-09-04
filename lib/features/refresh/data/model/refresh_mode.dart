import 'package:flutter/material.dart';

import '../care_duration_split.dart';

/// 리프레시 칩 탭 라벨.
class RefreshModeTabs {
  const RefreshModeTabs._();

  static const allTab = '전체';

  static const customModeTab = '커스텀';

  static const all = [
    allTab,
    customModeTab,
    beforeOuting,
    afterOuting,
    weather,
    etc,
  ];

  static int get customTabIndex => all.indexOf(customModeTab);

  /// 커스텀 모드 기본 카테고리(내부·DB).
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
    this.createdAt,
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
  final DateTime? createdAt;

  /// 먼지·냄새 없이 향기 케어만 수행하는 모드인지 여부.
  bool get isScentOnlyCare => scentYn && !dustYn && !odorYn;

  bool get isDeletable => isCustom || createdByUser;

  String get durationLabel =>
      CareDurationSplit.formatKoreanTime(durationSeconds);

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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
