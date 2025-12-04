import 'package:flutter/material.dart';
import 'package:glcgate/core/helper/responsive.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';
import 'package:glcgate/features/products/presentation/widgets/product_grid/animated_product_card.dart';

class CategorySection extends StatelessWidget {
  final List<ProductItem> categoryItems;
  final String category;
  const CategorySection({
    super.key,
    required this.categoryItems,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final padding = _getGridPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            padding.left + 8,
            16,
            padding.right + 8,
            8,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${categoryItems.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _getGridColumns(context),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: _getCardHeight(context),
          ),
          itemCount: categoryItems.length,
          itemBuilder: (context, index) {
            return AnimatedProductCard(
              index: index,
              item: categoryItems[index],
            );
          },
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding.left),
          child: Divider(height: 1, thickness: 0.5, color: AppColors.grey200),
        ),
      ],
    );
  }

  /// Get grid padding based on screen size
  EdgeInsets _getGridPadding(BuildContext context) {
    final screenType = Responsive.getScreenType(context);
    return switch (screenType) {
      ScreenType.desktop => const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      ScreenType.tablet => const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      ScreenType.mobile => const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
    };
  }

  /// Calculate responsive grid columns based on screen width
  int _getGridColumns(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final screenType = Responsive.getScreenType(context);

    // For tablet/desktop with drawer, account for drawer width
    final effectiveWidth = switch (screenType) {
      ScreenType.desktop => width - 400,
      ScreenType.tablet => width - 350,
      ScreenType.mobile => width,
    };

    // Calculate columns based on card width
    final cardWidth = switch (screenType) {
      ScreenType.desktop => 180.0,
      ScreenType.tablet => 160.0,
      ScreenType.mobile => 140.0,
    };

    final columns = (effectiveWidth / cardWidth).floor();
    return columns.clamp(3, 8);
  }

  /// Get card height based on screen size
  double _getCardHeight(BuildContext context) {
    final screenType = Responsive.getScreenType(context);
    return switch (screenType) {
      ScreenType.desktop => 215.0,
      ScreenType.tablet => 210.0,
      ScreenType.mobile => 205.0,
    };
  }
}
