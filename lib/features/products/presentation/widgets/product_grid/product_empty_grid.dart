import 'package:flutter/material.dart'; 
import '../../../../../core/theme/app_colors.dart';

class ProductEmptyGrid extends StatelessWidget {
  const ProductEmptyGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.grey200.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.greyColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد منتجات متاحة',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.greyDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
