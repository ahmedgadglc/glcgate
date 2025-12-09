import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/extensions/responsive_extension.dart';
import 'package:glcgate/core/helper/responsive.dart';
import 'package:glcgate/core/theme/app_colors.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';
import 'package:glcgate/features/products/presentation/cubit/products_cubit.dart';
import 'package:glcgate/features/products/presentation/widgets/bottom_sheet.dart';
import 'package:glcgate/features/products/presentation/widgets/product_image_card.dart';

class ProductCard extends StatefulWidget {
  final ProductItem item;
  final int? index;

  const ProductCard({super.key, required this.item, this.index});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isHovered = false;

  bool _shouldEnableHover(BuildContext context) {
    return !Responsive.isMobile(context) || kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    final shouldEnableHover = _shouldEnableHover(context);

    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        // Check if this item is in cart and count distinct items
        final matchingCartItems = state.cartItems.where((cartItem) {
          return cartItem.productDescription == widget.item.productDescription;
        }).toList();

        final isInCart = matchingCartItems.isNotEmpty;
        final itemCount = matchingCartItems.length;

        Widget cardContent = Padding(
          padding: const EdgeInsets.all(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // Set selected item for AddProductCardView
              context.read<ProductsCubit>().setSelectproductDescription(
                widget.item,
              );

              // On mobile, show bottom sheet
              if (Responsive.isMobile(context)) {
                showAddProductBottomSheet(context);
              }
            },
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag:
                            'product-${widget.item.itemCode ?? widget.item.itemID}',
                        child: ProductImageCard(
                          imageUrl: widget.item.itemURL,
                          productDescription: widget.item.productDescription,
                          width: context.isDesktop ? 142 : 120,
                          height: context.isDesktop ? 142 : 120,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            widget.item.productDescription ?? '',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: AppColors.greyColor,
                                  fontSize: 14,
                                ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
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
        );

        // Wrap with hover detection and scale animation for desktop/web
        if (shouldEnableHover) {
          return MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedScale(
              scale: _isHovered ? 1.05 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: cardContent,
            ),
          );
        }

        return cardContent;
      },
    );
  }
}
