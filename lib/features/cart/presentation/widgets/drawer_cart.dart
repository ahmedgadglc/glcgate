import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../screens/cart_screen.dart';

/// Cart drawer for desktop/tablet view matching glcecho's design
class DrawerCart extends StatelessWidget {
  final double width;

  const DrawerCart({
    super.key,
    this.width = 500, // Match glcecho width
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      child: Container(
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
        ),
        child: const CartScreen(showHeader: true),
      ),
    );
  }
}
