import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/cubit/products_cubit.dart';

class CartAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CartAppBar({super.key});

  @override
  Widget build(BuildContext context) {
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
                onPressed: () => showClearCartDialog(context),
                tooltip: 'مسح السلة',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void showClearCartDialog(BuildContext context) {
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
