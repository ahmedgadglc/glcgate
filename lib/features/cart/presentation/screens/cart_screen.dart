import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/features/cart/presentation/widgets/cart_app_bar.dart';
import 'package:glcgate/features/cart/presentation/widgets/custom_drawer_header.dart';
import 'package:glcgate/features/cart/presentation/widgets/custom_floating_add_product_button.dart';

import '../../../../core/helper/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../widgets/animated_cart_list.dart';
import '../widgets/cart_footer.dart';

class CartScreen extends StatelessWidget {
  final bool showHeader;

  const CartScreen({super.key, this.showHeader = true});

  @override
  Widget build(BuildContext context) {
    final bool isMobile = Responsive.isMobile(context);

    if (showHeader && isMobile) {
      return Scaffold(
        appBar: CartAppBar(),
        body: _buildBody(context, isMobile),
      );
    }

    return _buildBody(context, isMobile);
  }

  Widget _buildBody(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.grey.shade50,
      child: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          return Column(
            children: [
              if (!isMobile && showHeader) CustomDrawerHeader(),

              if (!isMobile && state.cartItems.isNotEmpty)
                _buildClearCartRow(context, state),

              Expanded(
                child: Stack(
                  children: [
                    AnimatedCartList(
                      items: state.cartItems,
                      isLoading: state.isLoading,
                    ),
                    // Floating add button for mobile only
                    if (isMobile && state.cartItems.isNotEmpty)
                      CustomFloatingAddProductButton(),
                  ],
                ),
              ),

              CartFooter(onCheckout: () => _handleCheckout(context)),
            ],
          );
        },
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
              color: AppColors.errorColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.delete_sweep,
                color: AppColors.errorColor,
                size: 20,
              ),
              onPressed: () => CartAppBar().showClearCartDialog(context),
              tooltip: 'حذف السلة',
            ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة وظيفة إتمام الطلب قريباً'),
        backgroundColor: AppColors.infoColor,
      ),
    );
  }
}
