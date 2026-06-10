import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_component_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/model/refresh_progress_session.dart';
import '../../data/refresh_mode_catalog.dart';
import '../widgets/refresh_progress_ring.dart';
import '../widgets/refresh_progress_step_strip.dart';

/// Figma Design `리프레시 > 모드 작동` (793:15950 · 823:25441).
class RefreshProgressPage extends StatefulWidget {
  const RefreshProgressPage({this.mode, super.key});

  final RefreshMode? mode;

  @override
  State<RefreshProgressPage> createState() => _RefreshProgressPageState();
}

class _RefreshProgressPageState extends State<RefreshProgressPage> {
  late final RefreshProgressSession _session;
  late int _totalRemainingSeconds;
  late int _stepRemainingSeconds;
  late int _activeStepIndex;

  Timer? _timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _session = RefreshProgressSession.fromMode(
      widget.mode ?? RefreshMode.samples.last,
    );
    _totalRemainingSeconds = _session.totalDurationSeconds;
    _activeStepIndex = 0;
    _stepRemainingSeconds = _session.steps.first.durationSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_isPaused || _totalRemainingSeconds <= 0) {
      return;
    }

    setState(() {
      _totalRemainingSeconds--;
      _stepRemainingSeconds--;

      if (_stepRemainingSeconds <= 0 &&
          _activeStepIndex < _session.steps.length - 1) {
        _activeStepIndex++;
        _stepRemainingSeconds =
            _session.steps[_activeStepIndex].durationSeconds;
      }
    });
  }

  RefreshProgressStep get _currentStep => _session.steps[_activeStepIndex];

  double get _progress {
    final total = _session.totalDurationSeconds;
    if (total == 0) {
      return 0;
    }
    return 1 - (_totalRemainingSeconds / total);
  }

  String get _percentLabel => '${(_progress * 100).round()}%';

  String _formatClock(int seconds) {
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
  }

  String get _pausedHint {
    final nextStep = _session.steps[_activeStepIndex].label;
    return '이어서 진행하면 $nextStep부터 계속돼요.';
  }

  Future<void> _confirmStop() async {
    final result = await AppConfirmDialog.show(
      context,
      title: '리프레시를 중단할까요?',
      message: '지금 나가면 진행 중인 \n리프레시를 이어 나가지 못해요.',
      primaryLabel: '종료',
      secondaryLabel: '취소',
    );

    if (!mounted || result != true) {
      return;
    }

    context.pop();
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  @override
  Widget build(BuildContext context) {
    final step = _currentStep;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmStop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.gray0,
        appBar: AppCommonTopHeader(
          variant: AppCommonTopHeaderVariant.gnb,
          title: '리프레시하기',
          onBack: _confirmStop,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, AppSpacing.lg, 15, 0),
                child: Column(
                  children: [
                    Text(
                      _session.modeName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineL.copyWith(
                        color: AppColors.primary700,
                        fontSize: 24,
                        height: 30 / 24,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RefreshProgressRing(
                      progress: _progress,
                      percentLabel: _percentLabel,
                      remainingLabel: _formatClock(_totalRemainingSeconds),
                      dimmed: _isPaused,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RefreshProgressStepStrip(
                      steps: _session.steps,
                      activeIndex: _activeStepIndex,
                      dimmed: _isPaused,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: 330,
                      child: _isPaused
                          ? Column(
                              children: [
                                Text(
                                  '리프레시가 잠시 멈췄어요.',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleS.copyWith(
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _pausedHint,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyXs.copyWith(
                                    color: AppColors.gray700,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Text(
                                  step.statusMessage,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleS.copyWith(
                                    color: AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _session.deviceGuide,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyXs.copyWith(
                                    color: AppColors.gray700,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return ColoredBox(
      color: AppComponentColors.bottomBarBackground,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Center(
            child: AppBoxButton(
              label: _isPaused ? '진행하기' : '일시 정지',
              onPressed: _togglePause,
              size: AppBoxButtonSize.small,
              variant: AppBoxButtonVariant.line,
            ),
          ),
        ),
      ),
    );
  }
}

/// [GoRouter] extra 로 전달된 모드를 [RefreshProgressPage]에 맞게 해석합니다.
RefreshMode? resolveRefreshProgressMode(Object? extra) {
  if (extra is RefreshMode) {
    return extra;
  }
  if (extra is String) {
    for (final mode in getAllRefreshModes()) {
      if (mode.name == extra) {
        return mode;
      }
    }
  }
  return null;
}
