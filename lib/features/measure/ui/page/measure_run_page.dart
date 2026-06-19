import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/app_text.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../data/model/measure_run_stage.dart';
import '../widgets/measure_prepare_instruction.dart';
import '../widgets/measure_progress_ring.dart';

/// Figma `진단_진단 중` (40000056:17484 · phone), 태블릿 (40000056:17581).
class MeasureRunPage extends StatefulWidget {
  const MeasureRunPage({super.key});

  @override
  State<MeasureRunPage> createState() => _MeasureRunPageState();
}

class _MeasureRunPageState extends State<MeasureRunPage>
    with SingleTickerProviderStateMixin {
  static const Duration _totalDuration = Duration(seconds: 12);
  static const Duration _completionHold = Duration(milliseconds: 700);

  /// Figma phone — 헤더 하단(76) → 원 상단(204) = 128.
  static const double _phoneRingTopFromBody = 128;

  /// Figma tablet — 화면 상단 기준 원 상단 350.
  static const double _tabletRingTopFromScreen = 350;

  /// Figma GNB 헤더 높이.
  static const double _gnbHeaderHeight = 52;

  /// Figma — 원(220)과 안내 문구 사이 40.
  static const double _ringToTextGap = 40;

  static const double _horizontalPadding =
      AppCommonTopHeader.pageHorizontalInset;

  static const double _stopButtonBottom = 56;
  static const double _tabletBreakpoint = 600;

  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _totalDuration)
        ..addListener(_onTick)
        ..addStatusListener(_onStatus);

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..removeStatusListener(_onStatus)
      ..dispose();
    super.dispose();
  }

  double get _progress => _controller.value;

  MeasureRunStage get _stage => MeasureRunStage.fromProgress(_progress);

  void _onTick() => setState(() {});

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _navigated) {
      return;
    }
    _navigated = true;
    Future<void>.delayed(_completionHold, () {
      if (mounted) {
        context.pushReplacementNamed(AppRouteNames.measureAnalyzing);
      }
    });
  }

  Future<void> _requestStop() async {
    if (_navigated) {
      return;
    }

    final wasRunning = _controller.isAnimating;
    _controller.stop();

    final confirmed = await AppConfirmDialog.show(
      context,
      title: '진단을 중단할까요?',
      message: '지금 나가면 진행 중인 진단 결과는\n저장되지 않아요.',
      primaryLabel: '종료',
      secondaryLabel: '취소',
    );

    if (!mounted) {
      return;
    }

    if (confirmed == true) {
      context.goHome();
    } else if (wasRunning && _progress < 1.0) {
      _controller.forward();
    }
  }

  bool _isTabletLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= _tabletBreakpoint;
  }

  double _ringTopFromBody(BuildContext context) {
    if (_isTabletLayout(context)) {
      final appBarBottom = MediaQuery.paddingOf(context).top + _gnbHeaderHeight;
      return _tabletRingTopFromScreen - appBarBottom;
    }
    return _phoneRingTopFromBody;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '헤어 상태 진단하기',
        onBack: _requestStop,
      ),
      body: Stack(
        children: [
          Positioned(
            top: _ringTopFromBody(context),
            left: _horizontalPadding,
            right: _horizontalPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: MeasureProgressRing(progress: _progress)),
                const SizedBox(height: _ringToTextGap),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: MeasurePrepareInstruction(
                    key: ValueKey(_stage),
                    title: _stage.title,
                    subtitle: _stage.subtitle,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: _stopButtonBottom + bottomInset,
            child: Center(
              child: TextButton(
                onPressed: _navigated ? null : _requestStop,
                child: AppText(
                  '중단하기',
                  style: AppTextStyles.labelM.copyWith(
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
