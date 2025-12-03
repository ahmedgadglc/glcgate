import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/helper/responsive.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';
import 'package:glcgate/features/products/presentation/widgets/bottom_sheet.dart';
import 'package:glcgate/features/products/presentation/widgets/product_image_card.dart';

class ProductCard extends StatelessWidget {
  final ProductItem item;
  final int? index;

  const ProductCard({super.key, required this.item, this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        // Check if this item is in cart and count distinct items
        final matchingCartItems = state.cartItems
            .where(
              (cartItem) =>
                  cartItem.itemMainDescription == item.itemMainDescription,
            )
            .toList();
        final isInCart = matchingCartItems.isNotEmpty;
        final itemCount = matchingCartItems.length;

        return Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Set selected item for AddProductCardView
              context.read<ProductsCubit>().setSelectItemMainDescription(item);

              // On mobile, show bottom sheet
              if (Responsive.isMobile(context)) {
                showAddProductBottomSheet(context);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: isInCart
                    ? Border.all(
                        color: AppColors.primaryColor.withAlpha(128),
                        width: 2,
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'product-${item.itemCode ?? item.itemID}',
                        child: ProductImageCard(
                          imageUrl: item.uRL,
                          itemMainDescription: item.itemMainDescription,
                          width: 120,
                          height: 120,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            item.itemMainDescription ?? '',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.greyColor,
                                  fontSize: 12,
                                ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Cart badge
                  if (isInCart)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              itemCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
