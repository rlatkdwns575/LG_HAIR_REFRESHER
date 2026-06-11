import 'package:flutter/material.dart';

/// 리프레시 화면에서 사용하는 모드 분류.
///
/// [label] 은 칩 탭과 배지에 그대로 노출됩니다.
enum RefreshModeCategory {
  customMode('커스텀 모드'),
  dust('먼지 제거'),
  care('케어'),
  normal('Normal');

  const RefreshModeCategory(this.label);

  final String label;
}

/// 리프레시 모드 화면 데이터 모델.
///
/// 현재는 화면 구현용 mock 데이터를 [samples] 로 제공하고,
/// 추후 `data/api` 에서 Supabase 응답을 이 모델로 변환합니다.
class RefreshMode {
  const RefreshMode({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.durationMinutes,
    required this.icon,
    this.tags = const [],
    this.isCustom = false,
    this.createdByUser = false,
  });

  /// 사용자가 직접 만든 커스텀 모드를 생성합니다.
  ///
  /// 분류는 항상 [RefreshModeCategory.customMode] 로 고정됩니다.
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
      category: RefreshModeCategory.customMode,
      durationMinutes: durationMinutes,
      icon: Icons.tune_outlined,
      tags: tags,
      isCustom: true,
      createdByUser: true,
    );
  }

  final String id;
  final String name;
  final String description;
  final RefreshModeCategory category;
  final int durationMinutes;
  final IconData icon;
  final List<String> tags;
  final bool isCustom;
  final bool createdByUser;

  /// 사용자가 직접 만든 모드만 삭제 가능.
  bool get isDeletable => isCustom || createdByUser;

  String get durationLabel => '$durationMinutes분';

  RefreshMode copyWith({
    String? id,
    String? name,
    String? description,
    RefreshModeCategory? category,
    int? durationMinutes,
    IconData? icon,
    List<String>? tags,
    bool? isCustom,
    bool? createdByUser,
  }) {
    return RefreshMode(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      isCustom: isCustom ?? this.isCustom,
      createdByUser: createdByUser ?? this.createdByUser,
    );
  }

  static const List<RefreshMode> samples = [
    RefreshMode(
      id: 'scalp-deep-care',
      name: '두피 딥케어',
      description: '진단 결과 두피 유분이 높아요.\n시원한 바람으로 두피를 집중 케어합니다.',
      category: RefreshModeCategory.care,
      durationMinutes: 12,
      icon: Icons.spa_outlined,
      tags: ['저온풍', '두피 집중'],
    ),
    RefreshMode(
      id: 'quick-refresh',
      name: '퀵 리프레시',
      description: '외출 직전 모발을 빠르게 정돈하고\n잔향을 가볍게 날려줍니다.',
      category: RefreshModeCategory.normal,
      durationMinutes: 3,
      icon: Icons.bolt_outlined,
      tags: ['강풍', '데일리'],
    ),
    RefreshMode(
      id: 'fine-dust',
      name: '미세먼지 털기',
      description: '외출 후 모발에 쌓인 미세먼지와\n꽃가루를 강풍으로 제거합니다.',
      category: RefreshModeCategory.dust,
      durationMinutes: 8,
      icon: Icons.air_outlined,
      tags: ['강풍', '외출 후'],
    ),
    RefreshMode(
      id: 'odor-care',
      name: '냄새 제거',
      description: '음식·담배 냄새가 밴 모발을\n탈취 모드로 리프레시합니다.',
      category: RefreshModeCategory.dust,
      durationMinutes: 6,
      icon: Icons.local_florist_outlined,
      tags: ['탈취', '중풍'],
    ),
    RefreshMode(
      id: 'night-care',
      name: '취침 전 케어',
      description: '잠들기 전 두피를 진정시키는\n저소음 저온풍 케어입니다.',
      category: RefreshModeCategory.care,
      durationMinutes: 10,
      icon: Icons.nightlight_outlined,
      tags: ['저소음', '저온풍'],
    ),
  ];
}
