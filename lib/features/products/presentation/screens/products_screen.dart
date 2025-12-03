import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cart_badge.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../cart/presentation/widgets/drawer_cart.dart';
import '../cubit/products_cubit.dart';
import '../widgets/add_product_card_view.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_search_bar.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // GlobalKey for cart icon to track position for fly-to-cart animation
  final GlobalKey _cartIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsCubit>().fetchProducts();
      // Store cart icon key in cubit for animation access
      context.read<ProductsCubit>().setCartIconKey(_cartIconKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Responsive(
          mobile: _buildMobileLayout(context),
          tablet: _buildTabletLayout(context),
          desktop: _buildDesktopLayout(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('المنتجات'),
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        if (Responsive.isMobile(context))
          CartIconButton(
            iconKey: _cartIconKey,
            onPressed: () => _navigateToCart(context),
          ),
      ],
    );
  }

  void _navigateToCart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartScreen()),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return _buildProductsContent(context, showAddProductView: false);
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildProductsContent(context, showAddProductView: true),
        ),
        const DrawerCart(width: 350),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildProductsContent(context, showAddProductView: true),
        ),
        const DrawerCart(width: 500),
      ],
    );
  }

  Widget _buildProductsContent(
    BuildContext context, {
    required bool showAddProductView,
  }) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        if (state.errorMessage != null && !state.isLoading) {
          return _buildErrorState(context, state.errorMessage!);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProductSearchBar(),
            if (!state.isLoading) ...[
              if (state.categories1.isNotEmpty)
                CategoryFilterBar(
                  tabList: state.categories1,
                  filterType: CategoryFilterType.category1,
                ),
              if (state.categories2.isNotEmpty)
                CategoryFilterBar(
                  tabList: state.categories2,
                  filterType: CategoryFilterType.category2,
                ),
            ],
            // AddProductCardView for desktop/tablet (above product grid)
            if (showAddProductView) const AddProductCardView(),
            // Product grid
            const Expanded(child: ProductGrid()),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductsCubit>().fetchProducts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
