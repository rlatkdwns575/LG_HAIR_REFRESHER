import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../data/model/measure_run_stage.dart';
import '../widgets/measure_prepare_instruction.dart';
import '../widgets/measure_progress_ring.dart';

class MeasureRunPage extends StatefulWidget {
  const MeasureRunPage({super.key});

  @override
  State<MeasureRunPage> createState() => _MeasureRunPageState();
}

class _MeasureRunPageState extends State<MeasureRunPage>
    with SingleTickerProviderStateMixin {
  // 화면설계서 기준 진단 소요 시간 10~15초.
  static const Duration _totalDuration = Duration(seconds: 12);
  static const Duration _completionHold = Duration(milliseconds: 700);

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
    // 100% 완료 메시지를 잠깐 보여준 뒤 결과 화면으로 전환.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '헤어 상태 진단',
        onBack: _requestStop,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 진행률 + 안내 문구를 화면 전체 기준 중앙에 배치.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -44),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MeasureProgressRing(progress: _progress),
                      const SizedBox(height: AppSpacing.xl),
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
              ),
            ),
            // 중단하기는 하단에 고정 (중앙 정렬에 영향 주지 않도록 Stack 사용).
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Center(
                child: TextButton(
                  onPressed: _navigated ? null : _requestStop,
                  child: Text(
                    '중단하기',
                    style: AppTextStyles.labelL.copyWith(
                      color: AppColors.gray500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
