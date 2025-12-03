import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/products/presentation/cubit/products_cubit.dart';
import '../theme/app_colors.dart';

/// Simple cart badge widget that shows cart count on an icon
class CartBadge extends StatelessWidget {
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;
  final bool showZero;

  const CartBadge({
    super.key,
    required this.child,
    this.badgeColor,
    this.textColor = Colors.white,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final cartCount = state.cartItems.length;
        final shouldShow = showZero || cartCount > 0;

        return Badge(
          label: Text(
            cartCount > 99 ? '99+' : cartCount.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: badgeColor ?? AppColors.errorColor,
          isLabelVisible: shouldShow,
          child: child,
        );
      },
    );
  }
}

/// Cart icon button with badge for AppBar
class CartIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? badgeColor;
  final double iconSize;

  const CartIconButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: CartBadge(
        badgeColor: badgeColor,
        child: Icon(
          Icons.shopping_cart_outlined,
          color: iconColor ?? Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Cart count text widget
class CartCountText extends StatelessWidget {
  final TextStyle? style;
  final String prefix;
  final String suffix;

  const CartCountText({
    super.key,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return Text(
          '$prefix${state.cartItems.length}$suffix',
          style: style,
        );
      },
    );
  }
}

/// Cart status indicator
class CartStatusIndicator extends StatelessWidget {
  final Widget emptyChild;
  final Widget Function(int count) hasItemsBuilder;

  const CartStatusIndicator({
    super.key,
    required this.emptyChild,
    required this.hasItemsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        final cartCount = state.cartItems.length;
        if (cartCount > 0) {
          return hasItemsBuilder(cartCount);
        }
        return emptyChild;
      },
    );
  }
}
