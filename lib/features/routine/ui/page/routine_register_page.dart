import 'package:flutter/material.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_toggle.dart';
import '../../data/api/routine_alarm_scheduler.dart';
import '../../data/api/routine_api.dart';
import '../../data/model/routine.dart';
import '../widgets/routine_mode_picker.dart';
import '../widgets/routine_time_picker.dart';
import '../widgets/routine_weekday_picker.dart';

/// 반복 사용 패턴 카드에서 진입하는 루틴 알림 등록 화면.
class RoutineRegisterPage extends StatefulWidget {
  const RoutineRegisterPage({this.initial, super.key});

  /// 패턴 카드 등에서 전달한 prefill 값 (요일·시간).
  final Routine? initial;

  @override
  State<RoutineRegisterPage> createState() => _RoutineRegisterPageState();
}

class _RoutineRegisterPageState extends State<RoutineRegisterPage> {
  final _routineApi = const RoutineApi();

  List<RoutineModeOption> _modeOptions = const [];
  bool _isLoadingModes = true;

  String? _selectedModeId;
  String? _selectedModeName;
  late Set<int> _weekdays;
  late int _hour;
  late int _minute;
  bool _enabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _selectedModeId = initial?.modeId;
    _selectedModeName = initial?.modeName;
    _weekdays = {...?initial?.weekdays};
    _hour = initial?.hour ?? 19;
    _minute = initial?.minute ?? 0;
    _enabled = initial?.enabled ?? true;
    _loadModes();
  }

  Future<void> _loadModes() async {
    final options = await _routineApi.fetchModeOptions();
    if (!mounted) {
      return;
    }
    setState(() {
      _modeOptions = options;
      _isLoadingModes = false;
      if (_selectedModeId == null && _selectedModeName != null) {
        for (final option in options) {
          if (option.name == _selectedModeName) {
            _selectedModeId = option.id;
            break;
          }
        }
      }
      // prefill된 modeId의 이름을 옵션에서 보강합니다.
      if (_selectedModeId != null && _selectedModeName == null) {
        for (final option in options) {
          if (option.id == _selectedModeId) {
            _selectedModeName = option.name;
            break;
          }
        }
      }
    });
  }

  bool get _isEdit => widget.initial?.id != null;

  bool get _canSave =>
      _selectedModeId != null && _weekdays.isNotEmpty && !_isSaving;

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_weekdays.contains(weekday)) {
        _weekdays.remove(weekday);
      } else {
        _weekdays.add(weekday);
      }
    });
  }

  Future<void> _pickMode() async {
    final selected = await showRoutineModePicker(
      context: context,
      options: _modeOptions,
      selectedId: _selectedModeId,
    );
    if (selected == null) {
      return;
    }
    setState(() {
      _selectedModeId = selected.id;
      _selectedModeName = selected.name;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showRoutineTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _hour, minute: _minute),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _hour = picked.hour;
      _minute = picked.minute;
    });
  }

  Future<void> _save() async {
    if (!_canSave) {
      return;
    }
    setState(() => _isSaving = true);

    final routine = Routine(
      id: widget.initial?.id,
      modeId: _selectedModeId,
      modeName: _selectedModeName,
      weekdays: _weekdays,
      hour: _hour,
      minute: _minute,
      enabled: _enabled,
      createdAt: widget.initial?.createdAt,
    );

    try {
      final saved = _isEdit
          ? await _routineApi.update(routine)
          : await _routineApi.create(routine);
      final savedWithName = saved.copyWith(modeName: _selectedModeName);

      var scheduled = true;
      if (_enabled) {
        scheduled = await RoutineAlarmScheduler.schedule(savedWithName);
      } else {
        await RoutineAlarmScheduler.cancel(savedWithName);
      }

      if (!mounted) {
        return;
      }
      if (_enabled && !scheduled) {
        _showMessage('루틴은 저장됐지만 알림 권한이 없어 알림은 꺼져 있어요.');
      }
      Navigator.of(context).pop(true);
    } on RoutineApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      _showMessage('루틴을 저장하지 못했어요. 잠시 후 다시 시도해주세요.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: _isEdit ? '루틴 알림 수정' : '루틴 알림 등록',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: AppSystemInsets.pageHorizontal(
                  context,
                  top: AppSpacing.lg,
                  extraBottom: AppSpacing.lg,
                ),
                children: [
                  Text(
                    '반복되는 케어를 루틴으로 등록하면\n선택한 요일·시간에 알림을 보내드려요.',
                    style: AppTextStyles.bodyM2.copyWith(
                      color: AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Section(
                    title: '리프레시 모드',
                    child: _ModeRow(
                      label: _selectedModeName,
                      isLoading: _isLoadingModes,
                      isEmpty: !_isLoadingModes && _modeOptions.isEmpty,
                      onTap: _isLoadingModes || _modeOptions.isEmpty
                          ? null
                          : _pickMode,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Section(
                    title: '반복 요일',
                    child: RoutineWeekdayPicker(
                      selected: _weekdays,
                      onToggle: _toggleWeekday,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _Section(
                    title: '알림 시간',
                    child: _TimeRow(
                      label: RoutineWeekday.formatTime(_hour, _minute),
                      onTap: _pickTime,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ToggleRow(
                    title: '알림 받기',
                    caption: '선택한 요일·시간에 리프레시 알림을 보내요.',
                    value: _enabled,
                    onChanged: (value) => setState(() => _enabled = value),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                15,
                0,
                15,
                AppSpacing.md + AppSystemInsets.bottomOf(context),
              ),
              child: AppBoxButton(
                label: _isSaving
                    ? '저장 중...'
                    : _isEdit
                    ? '수정 완료'
                    : '루틴 등록',
                variant: _canSave
                    ? AppBoxButtonVariant.active
                    : AppBoxButtonVariant.disabled,
                onPressed: _canSave ? _save : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleXs.copyWith(color: AppColors.gray900),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.label,
    required this.isLoading,
    required this.isEmpty,
    required this.onTap,
  });

  final String? label;
  final bool isLoading;
  final bool isEmpty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = isLoading
        ? '모드를 불러오는 중...'
        : isEmpty
        ? '사용할 수 있는 모드가 없어요'
        : (label ?? '모드를 선택하세요');
    final isPlaceholder = label == null || isLoading || isEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.gray0,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyM1.copyWith(
                  color: isPlaceholder ? AppColors.gray400 : AppColors.gray900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              size: 22,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: AppColors.gray0,
          borderRadius: BorderRadius.circular(AppRadius.field),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyM1.copyWith(color: AppColors.gray900),
              ),
            ),
            const Icon(
              Icons.access_time_rounded,
              size: 20,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.caption,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String caption;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gray0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyM2.copyWith(
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppToggle(
            value: value,
            onChanged: onChanged,
            size: AppToggleSize.large,
          ),
        ],
      ),
    );
  }
}
