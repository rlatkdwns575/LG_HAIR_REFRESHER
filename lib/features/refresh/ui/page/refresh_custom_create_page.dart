import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_toggle.dart';
import '../../data/care_duration_split.dart';
import '../../data/custom_mode_store.dart';
import '../../data/model/refresh_mode.dart';

/// 케어 종류 (냄새 / 먼지 / 향기).
enum _CareType {
  odor('냄새 케어'),
  dust('먼지 케어'),
  scent('향기 케어');

  const _CareType(this.label);

  final String label;
}

/// 케어 강도 (집중관리 / 일반관리 / 간편관리).
enum _CareLevel {
  intensive('집중관리'),
  normal('일반관리'),
  simple('간편관리');

  const _CareLevel(this.label);

  final String label;

  CareIntensity get intensity => switch (this) {
    _CareLevel.intensive => CareIntensity.intensive,
    _CareLevel.normal => CareIntensity.normal,
    _CareLevel.simple => CareIntensity.simple,
  };
}

class RefreshCustomCreatePage extends StatefulWidget {
  const RefreshCustomCreatePage({super.key});

  @override
  State<RefreshCustomCreatePage> createState() =>
      _RefreshCustomCreatePageState();
}

class _RefreshCustomCreatePageState extends State<RefreshCustomCreatePage> {
  static const int _minDuration = 1;
  static const int _maxDuration = 30;

  final _nameController = TextEditingController();

  final Map<_CareType, bool> _enabled = {
    for (final type in _CareType.values) type: false,
  };
  final Map<_CareType, _CareLevel?> _levels = {
    for (final type in _CareType.values) type: null,
  };

  int _durationMinutes = _minDuration;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<_CareType> get _selectedCares =>
      _CareType.values.where((type) => _enabled[type] == true).toList();

  bool get _canSave {
    if (_nameController.text.trim().isEmpty) {
      return false;
    }
    final selected = _selectedCares;
    if (selected.isEmpty) {
      return false;
    }
    return selected.every((type) => _levels[type] != null);
  }

  void _toggleCare(_CareType type, bool value) {
    setState(() {
      _enabled[type] = value;
      if (!value) {
        _levels[type] = null;
      }
    });
  }

  void _selectLevel(_CareType type, _CareLevel level) {
    setState(() => _levels[type] = level);
  }

  Future<void> _openDurationPicker() async {
    final picked = await _DurationPickerSheet.show(
      context,
      initial: _durationMinutes,
      min: _minDuration,
      max: _maxDuration,
    );
    if (picked != null) {
      setState(() => _durationMinutes = picked);
    }
  }

  void _onSave() {
    if (!_canSave) {
      return;
    }

    final selected = _selectedCares;
    final tags = selected
        .map((type) => '${type.label} ${_levels[type]!.label}')
        .toList();
    final detail = '${tags.join(' · ')} · $_durationMinutes분 케어해요.';

    final mode = RefreshMode.custom(
      id: 'custom-${DateTime.now().microsecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: detail,
      durationMinutes: _durationMinutes,
      tags: tags,
    );

    CustomModeStore.instance.add(mode);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray0,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '커스텀 모드',
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                15,
                AppSpacing.lg,
                15,
                AppSpacing.lg,
              ),
              children: [
                _buildNameSection(),
                const SizedBox(height: AppSpacing.lg),
                _buildPreview(),
                const SizedBox(height: AppSpacing.lg),
                _buildCareSection(),
                const SizedBox(height: AppSpacing.xl),
                _buildDurationSection(),
              ],
            ),
          ),
          _buildSubmitBar(),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('모드 이름'),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: _nameController,
          hintText: '커스텀 리프레시 이름을 적어주세요',
          state: _nameController.text.isEmpty
              ? AppTextFieldState.empty
              : AppTextFieldState.typing,
          onChanged: (_) => setState(() {}),
          onClear: () {
            _nameController.clear();
            setState(() {});
          },
        ),
      ],
    );
  }

  /// 복합 케어 권장 순서: 먼지 제거 → 냄새 제거 → 향기 케어.
  static const List<_CareType> _previewOrder = [
    _CareType.dust,
    _CareType.odor,
    _CareType.scent,
  ];

  List<int> _previewDurationsSeconds(List<_CareType> selected) {
    final weights = selected
        .map(
          (type) => _levels[type] == null
              ? 0
              : CareDurationSplit.getCareRatio(_levels[type]!.intensity),
        )
        .toList();

    final positiveIndices = <int>[
      for (var i = 0; i < weights.length; i++)
        if (weights[i] > 0) i,
    ];
    if (positiveIndices.isEmpty) {
      return List.filled(selected.length, 0);
    }

    final split = CareDurationSplit.splitSeconds(
      totalMinutes: _durationMinutes,
      weights: [for (final i in positiveIndices) weights[i]],
    );

    final results = List<int>.filled(selected.length, 0);
    for (var i = 0; i < positiveIndices.length; i++) {
      results[positiveIndices[i]] = split[i];
    }
    return results;
  }

  Widget _buildPreview() {
    final selected = _previewOrder
        .where((type) => _enabled[type] == true)
        .toList();
    if (selected.isEmpty) {
      return const Divider(height: 1, color: AppColors.gray100);
    }

    final durationsSeconds = _previewDurationsSeconds(selected);

    return Stack(
      children: [
        // 점들이 얹히는 가로 연결선 (점 중심 높이에 맞춤).
        const Positioned(
          top: 4,
          left: 0,
          right: 0,
          child: Divider(height: 1, color: AppColors.gray100),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < selected.length; i++)
              Expanded(
                child: _PreviewItem(
                  careLabel: selected[i].label,
                  durationLabel: CareDurationSplit.formatKoreanTime(
                    durationsSeconds[i],
                  ),
                  level: _levels[selected[i]],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('무엇을 케어할까요?'),
        const SizedBox(height: AppSpacing.md),
        for (var i = 0; i < _CareType.values.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          _buildCareRow(_CareType.values[i]),
        ],
      ],
    );
  }

  Widget _buildCareRow(_CareType type) {
    final enabled = _enabled[type] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                type.label,
                style: AppTextStyles.bodyL.copyWith(color: AppColors.gray800),
              ),
            ),
            AppToggle(
              value: enabled,
              onChanged: (value) => _toggleCare(type, value),
            ),
          ],
        ),
        if (enabled) ...[
          const SizedBox(height: AppSpacing.sm),
          _CareLevelChips(
            selected: _levels[type],
            onSelected: (level) => _selectLevel(type, level),
          ),
        ],
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('몇 분동안 케어할까요?'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '복합 케어를 위해서는 7분 이상을 권장해요.',
          style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: AppSpacing.md),
        _DurationField(value: _durationMinutes, onTap: _openDurationPicker),
      ],
    );
  }

  Widget _buildSubmitBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          15,
          AppSpacing.sm,
          15,
          AppSpacing.md,
        ),
        child: AppBoxButton(
          label: '이 설정으로 시작하기',
          onPressed: _canSave ? _onSave : null,
          variant: _canSave
              ? AppBoxButtonVariant.active
              : AppBoxButtonVariant.disabled,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.titleS.copyWith(color: AppColors.gray800),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  const _PreviewItem({
    required this.careLabel,
    required this.durationLabel,
    required this.level,
  });

  final String careLabel;
  final String durationLabel;
  final _CareLevel? level;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary500,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          careLabel,
          style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray800),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              durationLabel,
              style: AppTextStyles.labelM.copyWith(color: AppColors.gray500),
            ),
            if (level != null) ...[
              const SizedBox(width: 4),
              Text(
                level!.label,
                style: AppTextStyles.labelM.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CareLevelChips extends StatelessWidget {
  const _CareLevelChips({required this.selected, required this.onSelected});

  final _CareLevel? selected;
  final ValueChanged<_CareLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _CareLevel.values.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _LevelChip(
              label: _CareLevel.values[i].label,
              selected: selected == _CareLevel.values[i],
              onTap: () => onSelected(_CareLevel.values[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary100 : AppColors.gray50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
        side: BorderSide(
          color: selected ? AppColors.primary500 : AppColors.gray100,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelM.copyWith(
                color: selected ? AppColors.primary500 : AppColors.gray500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({required this.value, required this.onTap});

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gray50,
      borderRadius: BorderRadius.circular(AppRadius.field),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: Center(
            child: Text(
              '$value분',
              style: AppTextStyles.titleXs.copyWith(color: AppColors.gray800),
            ),
          ),
        ),
      ),
    );
  }
}

/// 분을 휠로 굴려 선택하는 바텀시트.
class _DurationPickerSheet extends StatefulWidget {
  const _DurationPickerSheet({
    required this.initial,
    required this.min,
    required this.max,
  });

  final int initial;
  final int min;
  final int max;

  static Future<int?> show(
    BuildContext context, {
    required int initial,
    required int min,
    required int max,
  }) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.gray0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.dialog),
        ),
      ),
      builder: (_) =>
          _DurationPickerSheet(initial: initial, min: min, max: max),
    );
  }

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late int _selected = widget.initial;
  late final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: widget.initial - widget.min);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.max - widget.min + 1;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(_selected),
              child: Text(
                '저장',
                style: AppTextStyles.labelL.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: _controller,
              itemExtent: 40,
              onSelectedItemChanged: (index) =>
                  setState(() => _selected = widget.min + index),
              children: [
                for (var i = 0; i < count; i++)
                  Center(
                    child: Text(
                      '${widget.min + i}분',
                      style: AppTextStyles.titleS.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
