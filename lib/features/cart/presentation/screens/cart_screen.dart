import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../widgets/animated_cart_list.dart';
import '../widgets/cart_footer.dart';

/// Cart screen with animated list and floating add button for mobile
class CartScreen extends StatelessWidget {
  /// If true, shows header with back button (for standalone navigation)
  final bool showHeader;

  const CartScreen({super.key, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    if (showHeader && isMobile) {
      return Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context, isMobile),
      );
    }

    // For desktop/tablet drawer, no scaffold needed
    return _buildBody(context, isMobile);
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('السلة'),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            if (state.cartItems.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => _showClearCartDialog(context),
                tooltip: 'مسح السلة',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.grey.shade50,
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          return Column(
            children: [
              // Header for drawer (non-mobile)
              if (!isMobile && showHeader) _buildDrawerHeader(context),

              // Clear cart button row for drawer
              if (!isMobile && state.cartItems.isNotEmpty)
                _buildClearCartRow(context, state),

              // Cart items list with floating add button
              Expanded(
                child: Stack(
                  children: [
                    AnimatedCartList(
                      items: state.cartItems,
                      isLoading: state.isLoading,
                    ),
                    // Floating add button for mobile only
                    if (isMobile && state.cartItems.isNotEmpty)
                      _buildFloatingAddButton(context),
                  ],
                ),
              ),

              // Cart footer
              CartFooter(
                onCheckout: () => _handleCheckout(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey200),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            'السلة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          const Spacer(),
          BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.cartItems.length} منتج',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClearCartRow(BuildContext context, ProductsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.errorColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.delete_sweep,
                color: AppColors.errorColor,
                size: 20,
              ),
              onPressed: () => _showClearCartDialog(context),
              tooltip: 'حذف السلة',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAddButton(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Navigate back to products screen
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح السلة'),
        content: const Text('هل تريد حذف جميع المنتجات من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ProductsCubit>().clearCart();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context) {
    final state = context.read<ProductsCubit>().state;
    if (state.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد منتجات في السلة'),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    // TODO: Implement checkout functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة وظيفة إتمام الطلب قريباً'),
        backgroundColor: AppColors.infoColor,
      ),
    );
  }
}
