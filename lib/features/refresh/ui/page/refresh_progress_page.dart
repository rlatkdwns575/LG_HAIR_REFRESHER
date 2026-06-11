import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/model/refresh_progress_session.dart';
import '../../data/model/refresh_result.dart';
import '../../data/refresh_result_store.dart';
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
  bool _navigated = false;

  static const Duration _completionHold = Duration(milliseconds: 500);
  static const double _spacingBelowModeName = 40;
  static const double _spacingBelowRing = 36;
  static const double _spacingBelowStepStrip = 36;
  static const double _contentOffsetY = -84;
  static const double _pauseButtonBottom = 168;

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

    if (_totalRemainingSeconds <= 0) {
      _onComplete();
    }
  }

  void _onComplete() {
    if (_navigated) {
      return;
    }
    _navigated = true;
    _timer?.cancel();

    RefreshResultStore.instance.setPending(
      RefreshResult.fromProgressSession(session: _session, mode: widget.mode),
    );

    Future<void>.delayed(_completionHold, () {
      if (!mounted) {
        return;
      }
      context.pushReplacementNamed(AppRouteNames.refreshResultCollecting);
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
        body: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.2),
              child: Transform.translate(
                offset: const Offset(0, _contentOffsetY),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _session.modeName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineL.copyWith(
                          color: AppColors.primary700,
                          fontSize: 26,
                          height: 32 / 26,
                        ),
                      ),
                      const SizedBox(height: _spacingBelowModeName),
                      RefreshProgressRing(
                        progress: _progress,
                        remainingLabel: _formatClock(_totalRemainingSeconds),
                        dimmed: _isPaused,
                      ),
                      const SizedBox(height: _spacingBelowRing),
                      RefreshProgressStepStrip(
                        steps: _session.steps,
                        activeIndex: _activeStepIndex,
                        dimmed: _isPaused,
                      ),
                      const SizedBox(height: _spacingBelowStepStrip),
                      SizedBox(
                        width: 330,
                        child: _isPaused
                            ? Column(
                                children: [
                                  Text(
                                    '리프레시가 잠시 멈췄어요.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.titleM.copyWith(
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _pausedHint,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyM1.copyWith(
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
                                    style: AppTextStyles.titleM.copyWith(
                                      color: AppColors.gray900,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _session.deviceGuide,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyM1.copyWith(
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
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _pauseButtonBottom,
              child: _buildBottomAction(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return Center(
      child: AppBoxButton(
        label: _isPaused ? '진행하기' : '일시 정지',
        onPressed: _togglePause,
        size: AppBoxButtonSize.small,
        variant: AppBoxButtonVariant.line,
      ),
    );
  }
}
