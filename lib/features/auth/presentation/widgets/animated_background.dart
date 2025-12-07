import 'dart:math';

import 'package:flutter/material.dart';
import 'package:glcgate/core/theme/app_colors.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Create particles
    final random = Random();
    for (int i = 0; i < 30; i++) {
      _particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 3 + 1,
          speed: random.nextDouble() * 0.5 + 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightBlueColor,
                  const Color(0xFFB8D4F0),
                  Colors.white.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double angle;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  }) : angle = Random().nextDouble() * 2 * pi;
}

class BackgroundPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  BackgroundPainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw particles
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.15);

    for (final particle in particles) {
      // Animate particle position
      final x = (particle.x + animationValue * particle.speed) % 1.0;
      final y = (particle.y + animationValue * particle.speed * 0.5) % 1.0;

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        particle.size,
        paint,
      );
    }

    // Draw gradient overlay circles for depth
    final gradientPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.1), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.3, size.height * 0.2),
              radius: size.width * 0.4,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.2),
      size.width * 0.4,
      gradientPaint,
    );

    final gradientPaint2 = Paint()
      ..shader =
          RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.08), Colors.transparent],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.7, size.height * 0.8),
              radius: size.width * 0.5,
            ),
          );

    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.8),
      size.width * 0.5,
      gradientPaint2,
    );
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
