import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/products/presentation/cubit/products_cubit.dart';
import '../theme/app_colors.dart';

/// Simple cart badge widget that shows cart count on an icon with animations
class CartBadge extends StatefulWidget {
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
  State<CartBadge> createState() => _CartBadgeState();
}

class _CartBadgeState extends State<CartBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateBadge() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      buildWhen: (previous, current) =>
          previous.cartItems.length != current.cartItems.length,
      builder: (context, state) {
        final cartCount = state.cartItems.length;
        final shouldShow = widget.showZero || cartCount > 0;

        // Animate when count changes
        if (cartCount != _previousCount && cartCount > _previousCount) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _animateBadge();
          });
          _previousCount = cartCount;
        } else {
          _previousCount = cartCount;
        }

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Badge(
                label: Text(
                  cartCount > 99 ? '99+' : cartCount.toString(),
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: widget.badgeColor ?? AppColors.errorColor,
                isLabelVisible: shouldShow,
                child: widget.child,
              ),
            );
          },
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
  final GlobalKey? iconKey;

  const CartIconButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24,
    this.iconKey,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: iconKey,
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
        return Text('$prefix${state.cartItems.length}$suffix', style: style);
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
