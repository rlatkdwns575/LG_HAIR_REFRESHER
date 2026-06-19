import 'package:flutter/material.dart';

import '../../../../app/navigation/app_system_insets.dart';
import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_fixed_bottom_button_area.dart';
import '../../../../shared/widgets/app_toggle.dart';
import '../../data/api/routine_alarm_scheduler.dart';
import '../../data/api/routine_api.dart';
import '../../data/model/routine.dart';

/// 추천 알림(루틴) 목록 관리 화면.
class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  State<RoutineListPage> createState() => _RoutineListPageState();
}

class _RoutineListPageState extends State<RoutineListPage> {
  final _routineApi = const RoutineApi();

  List<Routine> _routines = const [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isMutating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _routineApi.fetchAll(),
        _routineApi.fetchModeOptions(),
      ]);
      if (!mounted) {
        return;
      }
      final routines = results[0] as List<Routine>;
      final options = results[1] as List<RoutineModeOption>;
      final nameById = {for (final option in options) option.id: option.name};

      setState(() {
        _routines = [
          for (final routine in routines)
            routine.copyWith(modeName: nameById[routine.modeId]),
        ];
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('RoutineListPage load failed: $error\n$stackTrace');
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = '추천 알림을 불러오지 못했어요.';
      });
    }
  }

  Future<void> _addRoutine() async {
    final saved = await context.pushRoutineRegister();
    if (saved == true && mounted) {
      await _load();
    }
  }

  Future<void> _editRoutine(Routine routine) async {
    final saved = await context.pushRoutineRegister(initial: routine);
    if (saved == true && mounted) {
      await _load();
    }
  }

  Future<void> _toggleRoutine(Routine routine, bool value) async {
    if (_isMutating) {
      return;
    }
    setState(() => _isMutating = true);

    final updated = routine.copyWith(enabled: value);
    try {
      await _routineApi.update(updated);
      if (value) {
        await RoutineAlarmScheduler.schedule(updated);
      } else {
        await RoutineAlarmScheduler.cancel(updated);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _routines = [
          for (final item in _routines)
            if (item.id == routine.id) updated else item,
        ];
        _isMutating = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isMutating = false);
      _showMessage('알림 상태를 변경하지 못했어요.');
    }
  }

  Future<void> _deleteRoutine(Routine routine) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '알림 삭제',
      message: '이 추천 알림을 삭제할까요?',
      primaryLabel: '삭제',
      secondaryLabel: '취소',
    );
    if (confirmed != true || !mounted) {
      return;
    }

    final id = routine.id;
    if (id == null) {
      return;
    }

    setState(() => _isMutating = true);
    try {
      await _routineApi.delete(id);
      await RoutineAlarmScheduler.cancel(routine);
      if (!mounted) {
        return;
      }
      setState(() {
        _routines = [
          for (final item in _routines)
            if (item.id != id) item,
        ];
        _isMutating = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _isMutating = false);
      _showMessage('알림을 삭제하지 못했어요.');
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
        title: '추천 알림 관리',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          AppFixedBottomButtonArea(
            child: AppBoxButton(
              label: '알림 추가',
              variant: AppBoxButtonVariant.active,
              onPressed: _addRoutine,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return _buildError();
    }
    if (_routines.isEmpty) {
      return _buildEmpty();
    }

    return ListView.separated(
      padding: AppSystemInsets.pageHorizontal(
        context,
        top: AppSpacing.lg,
        extraBottom: AppSpacing.sm,
      ),
      itemCount: _routines.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final routine = _routines[index];
        return _RoutineCard(
          routine: routine,
          onTap: () => _editRoutine(routine),
          onToggle: (value) => _toggleRoutine(routine, value),
          onDelete: () => _deleteRoutine(routine),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: AppColors.gray300,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '등록된 추천 알림이 없어요',
              style: AppTextStyles.titleS.copyWith(color: AppColors.gray900),
            ),
            const SizedBox(height: 6),
            Text(
              '아래 버튼으로 리프레시 알림을 추가해보세요.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyM2.copyWith(color: AppColors.gray700),
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: _load, child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.routine,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  final Routine routine;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = routine.scheduleLabel;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
                    routine.modeName ?? '리프레시 모드',
                    style: AppTextStyles.titleS.copyWith(
                      color: routine.enabled
                          ? AppColors.gray900
                          : AppColors.gray400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            AppToggle(
              value: routine.enabled,
              onChanged: onToggle,
              size: AppToggleSize.large,
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
