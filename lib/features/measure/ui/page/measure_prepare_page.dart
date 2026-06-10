import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/app_common_top_header.dart';
import '../../data/model/measure_prepare_step.dart';
import '../widgets/measure_prepare_body.dart';
import '../widgets/measure_prepare_bottom_bar.dart';
import '../widgets/measure_prepare_skeleton.dart';
import '../widgets/measure_step_indicator.dart';

class MeasurePreparePage extends StatefulWidget {
  const MeasurePreparePage({super.key});

  @override
  State<MeasurePreparePage> createState() => _MeasurePreparePageState();
}

class _MeasurePreparePageState extends State<MeasurePreparePage> {
  static const Duration _initialLoadDelay = Duration(milliseconds: 1500);
  static const Duration _stepAdvanceDelay = Duration(seconds: 2);

  MeasurePrepareViewState _viewState = MeasurePrepareViewState.loading;
  MeasurePrepareStep _currentStep = MeasurePrepareStep.devicePower;
  Timer? _mockTimer;

  @override
  void initState() {
    super.initState();
    _startInitialLoad();
  }

  @override
  void dispose() {
    _mockTimer?.cancel();
    super.dispose();
  }

  void _startInitialLoad() {
    _mockTimer = Timer(_initialLoadDelay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _viewState = MeasurePrepareViewState.loaded;
        _currentStep = MeasurePrepareStep.devicePower;
      });
      _scheduleStepAdvance();
    });
  }

  void _scheduleStepAdvance() {
    _mockTimer?.cancel();
    _mockTimer = Timer(_stepAdvanceDelay, () {
      if (!mounted) {
        return;
      }

      final nextStep = _currentStep.next;
      if (nextStep == null) {
        return;
      }

      setState(() {
        _currentStep = nextStep;
      });

      if (_currentStep != MeasurePrepareStep.ready) {
        _scheduleStepAdvance();
      }
    });
  }

  bool get _isStartEnabled => _currentStep == MeasurePrepareStep.ready;

  void _onStartPressed() {
    _mockTimer?.cancel();
    context.pushMeasureRun();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _viewState == MeasurePrepareViewState.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppCommonTopHeader(
        variant: AppCommonTopHeaderVariant.gnb,
        title: '현재 헤어 상태',
        onBack: () => context.pop(),
      ),
      body: isLoading
          ? const MeasurePrepareSkeleton()
          : Column(
              children: [
                MeasureStepIndicator(currentStep: _currentStep.index),
                Expanded(child: MeasurePrepareBody(step: _currentStep)),
                MeasurePrepareBottomBar(
                  label: '진단 시작',
                  enabled: _isStartEnabled,
                  onPressed: _onStartPressed,
                ),
              ],
            ),
    );
  }
}
