import 'dart:ui';

import 'package:flutter/material.dart';

/// 진단 결과 중앙 오브 그래픽 (Figma 621-12875/12885).
class MeasureResultOrb extends StatelessWidget {
  const MeasureResultOrb({super.key});

  static const double size = 220;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          _BlurOrb(
            color: Color(0x99667AFF),
            diameter: 190,
            offset: Offset(-12, 4),
          ),
          _BlurOrb(
            color: Color(0x99FF8A4C),
            diameter: 150,
            offset: Offset(18, -16),
          ),
          _BlurOrb(
            color: Color(0x884DE8C2),
            diameter: 120,
            offset: Offset(-8, 20),
          ),
          _BlurOrb(
            color: Color(0x66FFFFFF),
            diameter: 90,
            offset: Offset(0, -6),
          ),
        ],
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.color,
    required this.diameter,
    required this.offset,
  });

  final Color color;
  final double diameter;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
