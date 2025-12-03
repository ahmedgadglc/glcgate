import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/cart_screen.dart';

class DrawerCart extends StatelessWidget {
  final double width;

  const DrawerCart({super.key, this.width = 500});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child:
          Container(
                width: width,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  border: Border(
                    right: BorderSide(color: AppColors.grey200, width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey200.withAlpha(76),
                      blurRadius: 20,
                      offset: const Offset(-2, 0),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const CartScreen(showHeader: true),
              )
              .animate()
              .slideX(
                begin: 0.1,
                end: 0,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              )
              .fadeIn(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              ),
    );
  }
}
