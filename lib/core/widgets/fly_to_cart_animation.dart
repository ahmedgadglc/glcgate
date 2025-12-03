import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Widget that displays a product image flying along a curved path
class FlyToCartAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String? imageUrl;
  final VoidCallback? onComplete;
  final Duration duration;

  const FlyToCartAnimation({
    super.key,
    required this.startPosition,
    required this.endPosition,
    this.imageUrl,
    this.onComplete,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<FlyToCartAnimation> createState() => _FlyToCartAnimationState();
}

class _FlyToCartAnimationState extends State<FlyToCartAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Curved path animation using cubic bezier for natural arc motion
    _positionAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Scale: start at 1.0, scale down to 0.4 during flight, scale up to 0.6 at end
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.7,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 0.6)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.3,
      ),
    ]).animate(_controller);

    // Opacity: fade from 1.0 to 0.7 during flight, fade out at end
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.8,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.2,
      ),
    ]).animate(_controller);

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculate curved path position using quadratic bezier
  Offset _calculateCurvedPosition(double t) {
    // Control point for the arc (higher Y creates more arc)
    final controlPoint = Offset(
      (widget.startPosition.dx + widget.endPosition.dx) / 2,
      widget.startPosition.dy - 100, // Arc height
    );

    // Quadratic bezier curve: (1-t)²P₀ + 2(1-t)tP₁ + t²P₂
    final x = (1 - t) * (1 - t) * widget.startPosition.dx +
        2 * (1 - t) * t * controlPoint.dx +
        t * t * widget.endPosition.dx;
    final y = (1 - t) * (1 - t) * widget.startPosition.dy +
        2 * (1 - t) * t * controlPoint.dy +
        t * t * widget.endPosition.dy;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final position = _calculateCurvedPosition(_positionAnimation.value);
        final size = 70.0 * _scaleAnimation.value;

        return Positioned(
          left: position.dx - size / 2,
          top: position.dy - size / 2,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: widget.imageUrl != null &&
                          widget.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.shopping_cart,
                              color: AppColors.primaryColor,
                              size: 30,
                            ),
                          ),
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.shopping_cart,
                            color: AppColors.primaryColor,
                            size: 30,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

