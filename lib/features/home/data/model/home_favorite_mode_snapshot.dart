import 'package:flutter/material.dart';

import '../../../refresh/data/model/refresh_mode.dart';

/// 홈 즐겨찾기 로컬 저장용 [RefreshMode] 스냅샷.
class HomeFavoriteModeSnapshot {
  const HomeFavoriteModeSnapshot({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.durationSeconds,
    required this.tags,
    required this.isCustom,
    required this.createdByUser,
    required this.odorYn,
    required this.dustYn,
    required this.scentYn,
    this.odorStrength,
    this.dustStrength,
    this.scentStrength,
  });

  factory HomeFavoriteModeSnapshot.fromRefreshMode(RefreshMode mode) {
    return HomeFavoriteModeSnapshot(
      id: mode.id,
      name: mode.name,
      description: mode.description,
      category: mode.category,
      durationSeconds: mode.durationSeconds,
      tags: List<String>.from(mode.tags),
      isCustom: mode.isCustom,
      createdByUser: mode.createdByUser,
      odorYn: mode.odorYn,
      dustYn: mode.dustYn,
      scentYn: mode.scentYn,
      odorStrength: mode.odorStrength,
      dustStrength: mode.dustStrength,
      scentStrength: mode.scentStrength,
    );
  }

  factory HomeFavoriteModeSnapshot.fromJson(Map<String, dynamic> json) {
    return HomeFavoriteModeSnapshot(
      id: json['id'] as String,
      name: json['name'] as String? ?? '리프레시 모드',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? RefreshModeTabs.etc,
      durationSeconds: (json['duration_seconds'] as num?)?.round() ?? 0,
      tags: [
        for (final tag in json['tags'] as List<dynamic>? ?? const [])
          if (tag is String) tag,
      ],
      isCustom: json['is_custom'] == true,
      createdByUser: json['created_by_user'] == true,
      odorYn: json['odor_yn'] == true,
      dustYn: json['dust_yn'] == true,
      scentYn: json['scent_yn'] == true,
      odorStrength: _readInt(json['odor_strength']),
      dustStrength: _readInt(json['dust_strength']),
      scentStrength: _readInt(json['scent_strength']),
    );
  }

  final String id;
  final String name;
  final String description;
  final String category;
  final int durationSeconds;
  final List<String> tags;
  final bool isCustom;
  final bool createdByUser;
  final bool odorYn;
  final bool dustYn;
  final bool scentYn;
  final int? odorStrength;
  final int? dustStrength;
  final int? scentStrength;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'duration_seconds': durationSeconds,
    'tags': tags,
    'is_custom': isCustom,
    'created_by_user': createdByUser,
    'odor_yn': odorYn,
    'dust_yn': dustYn,
    'scent_yn': scentYn,
    if (odorStrength != null) 'odor_strength': odorStrength,
    if (dustStrength != null) 'dust_strength': dustStrength,
    if (scentStrength != null) 'scent_strength': scentStrength,
  };

  RefreshMode toRefreshMode() {
    return RefreshMode(
      id: id,
      name: name,
      description: description,
      category: category,
      durationSeconds: durationSeconds,
      icon: _iconForCategory(category),
      tags: tags,
      isCustom: isCustom,
      createdByUser: createdByUser,
      odorYn: odorYn,
      dustYn: dustYn,
      scentYn: scentYn,
      odorStrength: odorStrength,
      dustStrength: dustStrength,
      scentStrength: scentStrength,
    );
  }

  static int? _readInt(Object? value) {
    if (value is num) {
      return value.round();
    }
    return null;
  }

  static IconData _iconForCategory(String category) {
    return switch (category) {
      RefreshModeTabs.beforeOuting => Icons.directions_walk_outlined,
      RefreshModeTabs.afterOuting => Icons.home_outlined,
      RefreshModeTabs.weather => Icons.wb_sunny_outlined,
      RefreshModeTabs.customMode => Icons.tune_outlined,
      RefreshModeTabs.etc => Icons.auto_awesome_outlined,
      _ => Icons.auto_awesome_outlined,
    };
  }
}
