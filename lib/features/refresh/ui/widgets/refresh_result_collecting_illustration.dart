import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../data/refresh_assets.dart';

/// 리프레시 결과 수집 중 화면 일러스트.
///
/// PNG 3장만으로는 GIF처럼 완전히 매끄운 보간은 어렵습니다.
/// 스캔 진행(상단 → 중간 → 완료)에 맞춰 프레임을 천천히 유지·전환합니다.
class RefreshResultCollectingIllustration extends StatefulWidget {
  const RefreshResultCollectingIllustration({super.key});

  static const double height = 200;

  /// 4단계(3→2→4→3) 1사이클. 단계당 700ms.
  static const Duration cycleDuration = Duration(milliseconds: 2800);

  @override
  State<RefreshResultCollectingIllustration> createState() =>
      _RefreshResultCollectingIllustrationState();
}

class _RefreshResultCollectingIllustrationState
    extends State<RefreshResultCollectingIllustration>
    with SingleTickerProviderStateMixin {
  static const _frames = RefreshAssets.collectingIllustrationFrames;

  /// refresh3(상단) → refresh2(중간) → refresh4(완료) → refresh3(리셋).
  static const _sequence = [1, 0, 2, 1];

  late final AnimationController _controller;
  int _frameIndex = _sequence.first;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: RefreshResultCollectingIllustration.cycleDuration,
    );
    _controller.addListener(_syncFrameIndex);

    if (_frames.length > 1) {
      _controller.repeat();
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      for (final frame in _frames) {
        precacheImage(AssetImage(frame), context);
      }
    });
  }

  void _syncFrameIndex() {
    if (_frames.length <= 1) {
      return;
    }

    final segmentIndex =
        (_controller.value * _sequence.length).floor() % _sequence.length;
    final nextIndex = _sequence[segmentIndex];
    if (nextIndex == _frameIndex) {
      return;
    }

    setState(() => _frameIndex = nextIndex);
  }

  @override
  void dispose() {
    _controller.removeListener(_syncFrameIndex);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _frames[_frameIndex.clamp(0, _frames.length - 1)];

    return RepaintBoundary(
      child: SizedBox(
        width: double.infinity,
        height: RefreshResultCollectingIllustration.height,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          gaplessPlayback: true,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}
