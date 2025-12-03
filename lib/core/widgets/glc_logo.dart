import 'package:flutter/material.dart';
import 'package:glcgate/core/utils/assets_manager.dart';

class LogoGLC extends StatelessWidget {
  const LogoGLC({super.key, this.width = 100, this.color});
  final double? width;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AssetsManager.glcLogo,
      fit: BoxFit.contain,
      color: color,
      width: width,
    );
  }
}