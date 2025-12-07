import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glcgate/core/widgets/glc_logo.dart';

class AnimatedGlcLogo extends StatelessWidget {
  const AnimatedGlcLogo({super.key, this.width = 200, this.color});

  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return LogoGLC(width: width, color: color)
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeOut,
        )
        .then()
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3))
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 3000.ms,
          curve: Curves.easeInOut,
        );
  }
}
