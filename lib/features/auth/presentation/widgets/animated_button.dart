import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:glcgate/core/theme/app_colors.dart';

class AnimatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSuccess;
  final IconData? icon;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSuccess = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: isLoading || isSuccess
                  ? [
                      AppColors.primaryColor.shade400,
                      AppColors.primaryColor.shade600,
                    ]
                  : [
                      AppColors.primaryColor.shade600,
                      AppColors.primaryColor.shade800,
                    ],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading || isSuccess ? null : onPressed,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                alignment: Alignment.center,
                child: _buildContent(),
              ),
            ),
          ),
        )
        .animate(target: isLoading ? 1 : 0)
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.3));
  }

  Widget _buildContent() {
    if (isSuccess) {
      return const Icon(
        Iconsax.tick_circle_copy,
        color: Colors.white,
        size: 28,
      ).animate().scale(
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
        duration: 300.ms,
        curve: Curves.elasticOut,
      );
    }

    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
