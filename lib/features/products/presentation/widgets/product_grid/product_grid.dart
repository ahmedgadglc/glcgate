import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/features/products/presentation/widgets/product_grid/animated_product_card.dart';
import 'package:glcgate/features/products/presentation/widgets/product_grid/category_section.dart';
import 'package:glcgate/features/products/presentation/widgets/product_grid/product_empty_grid.dart';
import 'package:glcgate/features/products/presentation/widgets/product_grid/product_lodaing_grid.dart';
import '../../../../../core/helper/responsive.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../cubit/products_cubit.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ProductLoadingGrid();
        }

        if (state.isSearching && state.searchQuery.isNotEmpty) {
          return _buildSearchResults(context, state);
        }
        return _buildCategoryGrid(context, state);
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, ProductsState state) {
    final items = context.read<ProductsCubit>().filteredItems;

    if (items.isEmpty) {
      return _buildEmptySearchResults(context, state.searchQuery);
    }

    final padding = _getGridPadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: padding.horizontal / 2 + 8,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(Icons.search, size: 20, color: AppColors.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'نتائج البحث عن: "${state.searchQuery}"',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} منتج',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: padding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getGridColumns(context),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: _getCardHeight(context),
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return AnimatedProductCard(index: index, item: items[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySearchResults(BuildContext context, String searchQuery) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
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
                Icons.search_off,
                size: 64,
                color: AppColors.greyColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد نتائج للبحث',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.greyDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نجد أي منتجات تطابق "$searchQuery"',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.greyColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'جرب البحث بكلمات مختلفة أو تأكد من كتابة الكلمات بشكل صحيح',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductsCubit>().clearSearch();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('مسح البحث'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, ProductsState state) {
    final groupedItems = context.read<ProductsCubit>().groupedByCategory;
    final categories = groupedItems.keys.toList();

    if (categories.isEmpty) {
      return const ProductEmptyGrid();
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        final categoryItems = groupedItems[category]!;
        return CategorySection(
          categoryItems: categoryItems,
          category: category,
        );
      },
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
    final width = MediaQuery.of(context).size.width;
    final screenType = Responsive.getScreenType(context);

    // For tablet/desktop with drawer, account for drawer width
    final effectiveWidth = switch (screenType) {
      ScreenType.desktop => width - 400, // 400px drawer
      ScreenType.tablet => width - 350, // 350px drawer
      ScreenType.mobile => width,
    };

    // Calculate columns based on card width
    final cardWidth = switch (screenType) {
      ScreenType.desktop => 180.0,
      ScreenType.tablet => 160.0,
      ScreenType.mobile => 140.0,
    };

    final columns = (effectiveWidth / cardWidth).floor();
    return columns.clamp(2, 8); // Min 2, Max 8 columns
  }

  /// Get card height based on screen size
  double _getCardHeight(BuildContext context) {
    final screenType = Responsive.getScreenType(context);
    return switch (screenType) {
      ScreenType.desktop => 180.0,
      ScreenType.tablet => 210.0,
      ScreenType.mobile => 170.0,
    };
  }
}
