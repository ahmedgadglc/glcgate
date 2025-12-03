import 'package:flutter/material.dart';
import 'package:glcgate/features/products/presentation/widgets/product_grid/category_section.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/models/product_item.dart';
class ProductLoadingGrid extends StatelessWidget {
  const ProductLoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
   final groupedItems = _generateDummyData();
    final categories = groupedItems.keys.toList()..sort();

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, categoryIndex) {
          final category = categories[categoryIndex];
          final categoryItems = groupedItems[category]!;
          return CategorySection(categoryItems: categoryItems, category: category);
        },
      ),
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