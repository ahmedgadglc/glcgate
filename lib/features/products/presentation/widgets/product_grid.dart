import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/helper/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/product_item.dart';
import '../cubit/products_cubit.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return _buildLoadingGrid(context);
        }

        if (state.isSearching && state.searchQuery.isNotEmpty) {
          return _buildSearchResults(context, state);
        }

        return _buildCategoryGrid(context, state);
      },
    );
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
      ScreenType.desktop => 220.0,
      ScreenType.tablet => 210.0,
      ScreenType.mobile => 200.0,
    };
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

  Widget _buildLoadingGrid(BuildContext context) {
    final groupedItems = _generateDummyData();
    final categories = groupedItems.keys.toList()..sort();

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final category = categories[categoryIndex];
          final categoryItems = groupedItems[category]!;
          return _buildCategorySection(context, category, categoryItems);
        },
      ),
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
      return _buildEmptyState(context);
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, categoryIndex) {
        final category = categories[categoryIndex];
        final categoryItems = groupedItems[category]!;
        return _buildCategorySection(context, category, categoryItems);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    List<ProductItem> categoryItems,
  ) {
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

  Map<String, List<ProductItem>> _generateDummyData() {
    final categories = [
      'Interior Paints',
      'Exterior Paints',
      'Primers',
      'Stains',
      'Clear Coats',
    ];
    final Map<String, List<ProductItem>> grouped = {};

    for (int i = 0; i < 20; i++) {
      final category = categories[i % categories.length];
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(
        ProductItem(
          itemID: i,
          itemCode: 'CODE$i',
          itemMainDescription: 'Product $i',
          itemDescription: 'Description $i',
          priceSellingUM: 100.0 + i,
          itemCategory1Description: category,
          uRL: '',
        ),
      );
    }
    return grouped;
  }
}

class AnimatedProductCard extends StatefulWidget {
  final ProductItem item;
  final int index;

  const AnimatedProductCard({
    super.key,
    required this.item,
    required this.index,
  });

  @override
  State<AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Limit delay to prevent too long wait times
    final delay = (30 * (widget.index % 12)).clamp(0, 300);
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ProductCard(item: widget.item, index: widget.index),
      ),
    );
  }
}
