import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/cubit/products_cubit.dart';

class CartFooter extends StatelessWidget {
  final VoidCallback? onCheckout;

  const CartFooter({super.key, this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildNoteSection(context, state),
              const Divider(height: 1, thickness: 1),
              _buildSummaryCards(context, state),
              _buildActionButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoteSection(BuildContext context, ProductsState state) {
    return InkWell(
      onTap: () => _showNoteDialog(context, state.note ?? ''),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.note_alt_outlined, size: 20, color: AppColors.greyColor),
            const SizedBox(width: 8),
            const Text(
              'الملاحظات',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.note?.isNotEmpty == true
                    ? state.note!
                    : 'اضغط لإضافة ملاحظات...',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: state.note?.isNotEmpty == true
                      ? AppColors.greyDark
                      : AppColors.greyColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.greyColor),
          ],
        ),
      ),
    );
  }

  Future<void> _showNoteDialog(BuildContext context, String initialNote) async {
    final noteController = TextEditingController(text: initialNote);

    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ملاحظات'),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            autofocus: true,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              hintText: 'اكتب ملاحظاتك هنا...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<ProductsCubit>().setNote(noteController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, ProductsState state) {
    final grandTotal = state.totalAmount + state.totalTax;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildSummaryCard(
            context,
            title: 'الوزن',
            value: state.totalWeight,
            unit: 'كجم',
          ),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          _buildSummaryCard(
            context,
            title: 'القيمة',
            value: state.totalAmount,
            unit: 'جنيه',
          ),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          _buildSummaryCard(
            context,
            title: 'الضريبة',
            value: state.totalTax,
            unit: 'جنيه',
          ),
          const VerticalDivider(width: 1, indent: 8, endIndent: 8),
          _buildSummaryCard(
            context,
            title: 'الإجمالي',
            value: grandTotal,
            unit: 'جنيه',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required double value,
    required String unit,
    bool isBold = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(color: AppColors.greyDark, fontSize: 12),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _formatNumber(value),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                  color: isBold ? AppColors.primaryColor : AppColors.black,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style: TextStyle(color: AppColors.greyDark, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ProductsState state) {
    final hasItems = state.cartItems.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (hasItems)
            Expanded(
              child: ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'إتمام الطلب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (!hasItems)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'السلة فارغة',
                    style: TextStyle(fontSize: 16, color: AppColors.greyColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }
}