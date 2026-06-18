import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/device_consumable_service.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_box_button.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_text.dart';
import '../../data/model/refresh_mode.dart';
import '../../data/model/refresh_progress_session.dart';
import '../../data/refresh_mode_availability.dart';
import '../../data/refresh_mode_catalog.dart';
import '../../data/refresh_result_store.dart';
import '../refresh_scent_unavailable.dart';
import '../widgets/refresh_progress_ring.dart';
import '../widgets/refresh_progress_status_section.dart';
import '../widgets/refresh_progress_step_strip.dart';

/// Figma Design `리프레시 > 모드 작동` (40000026:27208 · 793:15950).
class RefreshProgressPage extends StatefulWidget {
  const RefreshProgressPage({this.mode, super.key});

  final RefreshMode? mode;

  @override
  State<RefreshProgressPage> createState() => _RefreshProgressPageState();
}

class _RefreshProgressPageState extends State<RefreshProgressPage> {
  late final RefreshProgressSession _session;
  late final RefreshMode _executedMode;
  late int _totalRemainingSeconds;
  late int _stepRemainingSeconds;
  late int _activeStepIndex;

  Timer? _timer;
  bool _isPaused = false;
  bool _navigated = false;

  static const Duration _completionHold = Duration(milliseconds: 500);
  static const double _spacingBelowModeName = 36;
  static const double _spacingBelowRing = 32;
  static const double _spacingBelowStepStrip = 28;
  static const double _spacingAboveButton = 28;
  static const double _phoneContentOffsetY = -20;

  /// Figma 750×800 태블릿 프레임 — 본문 세로 중심보다 약간 위.
  static const Alignment _tabletContentAlignment = Alignment(0, -0.12);

  static const double _tabletBreakpoint = 600;

  @override
  void initState() {
    super.initState();
    final mode = widget.mode ?? _resolveFallbackMode();
    _executedMode = mode;
    _session = RefreshProgressSession.fromMode(mode);
    _totalRemainingSeconds = _session.totalDurationSeconds;
    _activeStepIndex = 0;
    _stepRemainingSeconds = _session.steps.first.durationSeconds;
    _startTimer();
    unawaited(_validateScentCartridge(mode));
  }

  Future<void> _validateScentCartridge(RefreshMode mode) async {
    if (!mode.scentYn) {
      return;
    }

    final cartridge = await const DeviceConsumableService()
        .fetchScentCartridgeStatus();
    if (!RefreshModeAvailability.isEnabled(mode, cartridge) && mounted) {
      _timer?.cancel();
      showRefreshScentUnavailableSnackBar(context);
      context.pop();
    }
  }

  RefreshMode _resolveFallbackMode() {
    final modes = getAllRefreshModes();
    if (modes.isNotEmpty) {
      return modes.first;
    }

    return const RefreshMode(
      id: 'fallback-refresh',
      name: '리프레시',
      description: '모드를 불러오지 못했습니다.',
      category: RefreshModeTabs.beforeOuting,
      durationSeconds: 180,
      icon: Icons.bolt_outlined,
      dustYn: true,
    );
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

    RefreshResultStore.instance.setPendingMode(_executedMode);

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

    _timer?.cancel();
    context.pop();
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  bool _isTabletLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= _tabletBreakpoint;
  }

  Alignment _contentAlignment(BuildContext context) {
    return _isTabletLayout(context)
        ? _tabletContentAlignment
        : Alignment.center;
  }

  double _contentOffsetY(BuildContext context) {
    return _isTabletLayout(context) ? 0 : _phoneContentOffsetY;
  }

  Widget _buildProgressContent(RefreshProgressStep step) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          _session.modeName,
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineL.copyWith(
            color: AppColors.primary700,
            fontSize: 26,
            height: 32 / 26,
          ),
        ),
        const SizedBox(height: _spacingBelowModeName),
        Center(
          child: RefreshProgressRing(
            progress: _progress,
            remainingLabel: _formatClock(_totalRemainingSeconds),
            dimmed: _isPaused,
          ),
        ),
        const SizedBox(height: _spacingBelowRing),
        RefreshProgressStepStrip(
          steps: _session.steps,
          activeIndex: _activeStepIndex,
          dimmed: _isPaused,
        ),
        const SizedBox(height: _spacingBelowStepStrip),
        RefreshProgressStatusSection(
          isPaused: _isPaused,
          step: step,
          deviceGuide: _session.deviceGuide,
          pausedHint: _pausedHint,
        ),
      ],
    );
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(
                  alignment: _contentAlignment(context),
                  child: Transform.translate(
                    offset: Offset(0, _contentOffsetY(context)),
                    child: _buildProgressContent(step),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  15,
                  _spacingAboveButton,
                  15,
                  AppSpacing.sm,
                ),
                child: _buildBottomAction(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    return AppBoxButton(
      label: _isPaused ? '진행하기' : '일시 정지',
      onPressed: _togglePause,
      variant: AppBoxButtonVariant.line,
    );
  }
}
