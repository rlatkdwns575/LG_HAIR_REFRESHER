import 'package:flutter/material.dart';

import '../model/refresh_mode.dart';

class RefreshModeMapper {
  const RefreshModeMapper._();

  static const selectColumns =
      'mode_id, user_id, display_name, category, description, duration_time, '
      'custom_yn, odor_yn, dust_yn, scent_yn, '
      'odor_strength, dust_strength, scent_strength';

  static RefreshMode fromCustomModeRow(Map<String, dynamic> row) {
    return fromRefreshModeRow({...row, 'custom_yn': true});
  }

  static RefreshMode fromRefreshModeRow(Map<String, dynamic> row) {
    final odorYn = row['odor_yn'] == true;
    final dustYn = row['dust_yn'] == true;
    final scentYn = row['scent_yn'] == true;
    final odorStrength = _readInt(row['odor_strength']);
    final dustStrength = _readInt(row['dust_strength']);
    final scentStrength = _readInt(row['scent_strength']);
    final rawCategory = (row['category'] as String? ?? '').trim();
    final customYn = row['custom_yn'] == true;
    final descriptionText = (row['description'] as String?)?.trim() ?? '';
    final category = rawCategory.isEmpty ? RefreshModeTabs.etc : rawCategory;

    return RefreshMode(
      id: row['mode_id'] as String,
      name: row['display_name'] as String? ?? '리프레시 모드',
      description: descriptionText.isNotEmpty
          ? descriptionText
          : _buildDescription(
              odorYn: odorYn,
              dustYn: dustYn,
              scentYn: scentYn,
              category: rawCategory,
            ),
      category: category,
      durationSeconds: _readInt(row['duration_time']) ?? 0,
      icon: _iconForCategory(category),
      tags: _buildTags(
        odorYn: odorYn,
        dustYn: dustYn,
        scentYn: scentYn,
        odorStrength: odorStrength,
        dustStrength: dustStrength,
        scentStrength: scentStrength,
      ),
      isCustom: customYn,
      createdByUser: customYn,
      odorYn: odorYn,
      dustYn: dustYn,
      scentYn: scentYn,
      odorStrength: odorStrength,
      dustStrength: dustStrength,
      scentStrength: scentStrength,
    );
  }

  static String strengthLabel(int? strength) {
    if (strength == null) {
      return '일반관리';
    }
    if (strength >= 3) {
      return '집중관리';
    }
    if (strength <= 1) {
      return '간편관리';
    }
    return '일반관리';
  }

  static String careLabelForFlag({
    required String type,
    required bool enabled,
  }) {
    if (!enabled) {
      return '';
    }
    return switch (type) {
      'odor' => '냄새제거',
      'dust' => '먼지제거',
      'scent' => '향기케어',
      _ => '',
    };
  }

  static String stepCareName(String careLabel) {
    return switch (careLabel) {
      '냄새제거' => '냄새',
      '먼지제거' => '먼지',
      '향기케어' => '향기',
      _ => careLabel,
    };
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

  static String _buildDescription({
    required bool odorYn,
    required bool dustYn,
    required bool scentYn,
    required String category,
  }) {
    final cares = <String>[];
    if (dustYn) {
      cares.add('먼지');
    }
    if (odorYn) {
      cares.add('냄새');
    }
    if (scentYn) {
      cares.add('향');
    }

    if (cares.isEmpty) {
      return '$category 상황에 맞춰 모발을 리프레시해요.';
    }

    return '${cares.join('·')} 케어로 모발 컨디션을 정돈해요.';
  }

  static List<String> _buildTags({
    required bool odorYn,
    required bool dustYn,
    required bool scentYn,
    required int? odorStrength,
    required int? dustStrength,
    required int? scentStrength,
  }) {
    final tags = <String>[];
    if (dustYn) {
      tags.add('먼지 제거 ${strengthLabel(dustStrength)}');
    }
    if (odorYn) {
      tags.add('냄새 제거 ${strengthLabel(odorStrength)}');
    }
    if (scentYn) {
      tags.add('향 케어 ${strengthLabel(scentStrength)}');
    }
    return tags;
  }
}
