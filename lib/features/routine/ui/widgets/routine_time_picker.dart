import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';

/// 휠(스크롤) 방식 시간 선택 바텀시트.
///
/// 오전/오후 · 시(1–12) · 분(0–59)을 굴려서 선택하고 [TimeOfDay]를 반환합니다.
Future<TimeOfDay?> showRoutineTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: AppColors.gray0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.dialog),
      ),
    ),
    builder: (context) => _RoutineTimePickerSheet(initialTime: initialTime),
  );
}

class _RoutineTimePickerSheet extends StatefulWidget {
  const _RoutineTimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_RoutineTimePickerSheet> createState() =>
      _RoutineTimePickerSheetState();
}

class _RoutineTimePickerSheetState extends State<_RoutineTimePickerSheet> {
  static const double _itemExtent = 40;
  static const double _wheelHeight = 200;

  late int _periodIndex; // 0 = 오전, 1 = 오후
  late int _hourIndex; // 0–11 → 1시~12시
  late int _minuteIndex; // 0–59

  late final FixedExtentScrollController _periodController;
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final hour24 = widget.initialTime.hour;
    _periodIndex = hour24 < 12 ? 0 : 1;
    final displayHour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    _hourIndex = displayHour - 1;
    _minuteIndex = widget.initialTime.minute;

    _periodController = FixedExtentScrollController(initialItem: _periodIndex);
    _hourController = FixedExtentScrollController(initialItem: _hourIndex);
    _minuteController = FixedExtentScrollController(initialItem: _minuteIndex);
  }

  @override
  void dispose() {
    _periodController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay get _selectedTime {
    final displayHour = _hourIndex + 1; // 1–12
    final isPm = _periodIndex == 1;
    var hour24 = displayHour % 12; // 12 → 0
    if (isPm) {
      hour24 += 12;
    }
    return TimeOfDay(hour: hour24, minute: _minuteIndex);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '알림 시간',
              style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: _wheelHeight,
              child: Stack(
                children: [
                  // 가운데 선택 영역 하이라이트.
                  Center(
                    child: Container(
                      height: _itemExtent,
                      decoration: BoxDecoration(
                        color: AppColors.primary100,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _Wheel(
                          controller: _periodController,
                          itemExtent: _itemExtent,
                          itemCount: 2,
                          labelBuilder: (index) => index == 0 ? '오전' : '오후',
                          onChanged: (index) =>
                              setState(() => _periodIndex = index),
                        ),
                      ),
                      Expanded(
                        child: _Wheel(
                          controller: _hourController,
                          itemExtent: _itemExtent,
                          itemCount: 12,
                          labelBuilder: (index) => '${index + 1}시',
                          onChanged: (index) =>
                              setState(() => _hourIndex = index),
                        ),
                      ),
                      Expanded(
                        child: _Wheel(
                          controller: _minuteController,
                          itemExtent: _itemExtent,
                          itemCount: 60,
                          labelBuilder: (index) =>
                              '${index.toString().padLeft(2, '0')}분',
                          onChanged: (index) =>
                              setState(() => _minuteIndex = index),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppBoxButton(
              label: '확인',
              variant: AppBoxButtonVariant.active,
              onPressed: () => Navigator.of(context).pop(_selectedTime),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.itemExtent,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final double itemExtent;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: itemExtent,
      squeeze: 1.1,
      diameterRatio: 1.4,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: onChanged,
      children: [
        for (var i = 0; i < itemCount; i++)
          Center(
            child: Text(
              labelBuilder(i),
              style: AppTextStyles.titleM.copyWith(color: AppColors.gray900),
            ),
          ),
      ],
    );
  }
}
