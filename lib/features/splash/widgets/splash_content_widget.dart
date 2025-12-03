import 'package:flutter/material.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/core/widgets/glc_logo.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LogoGLC(width: 300),
        const SizedBox(height: 16),
        LoadingAnimationWidget.hexagonDots(
          color: AppColors.primaryColor,
          size: 50.0,
        ),
      ],
    );
  }
}
