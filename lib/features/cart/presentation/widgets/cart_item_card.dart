import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/helper/app_function.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../products/data/models/product_item.dart';
import '../../../products/presentation/cubit/products_cubit.dart';
import '../../../products/presentation/widgets/product_image_card.dart';

/// Cart item card matching glcecho's ProductCardInCart design
class CartItemCard extends StatelessWidget {
  final ProductItem item;
  final VoidCallback? onRemove;

  const CartItemCard({super.key, required this.item, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.grey200.withOpacity(.7), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductImageCard(
              productDescription: item.productDescription ?? '',
              imageUrl: item.itemURL,
              width: 100,
              height: 100,
            ),
            const SizedBox(width: 2),
            Expanded(
              child: _ProductDetails(item: item, onRemove: onRemove),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetails extends StatelessWidget {
  final ProductItem item;
  final VoidCallback? onRemove;

  const _ProductDetails({required this.item, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                item.itemCategoryDescription1 ?? '',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.infoColor),
              ),
            ),
            SizedBox(
              height: 20,
              child: _DeleteButton(item: item, onRemove: onRemove),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productDescription ?? '',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.greyColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _ProductTags(item: item),
                  const SizedBox(height: 4),
                  Text(
                    item.itemCode ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _QuantityControls(item: item),
          ],
        ),
      ],
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final ProductItem item;
  final VoidCallback? onRemove;

  const _DeleteButton({required this.item, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => _showDeleteConfirmation(context),
        child: const Padding(
          padding: EdgeInsets.all(2),
          child: Icon(
            Icons.delete_outline,
            size: 16,
            color: AppColors.errorColor,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل تريد حذف "${item.productDescription}" من السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (item.itemID != null) {
                context.read<ProductsCubit>().removeFromCart(item.itemID!);
              }
              onRemove?.call();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.errorColor),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

class _ProductTags extends StatelessWidget {
  final ProductItem item;

  const _ProductTags({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (item.packingDescription != null &&
            item.packingDescription!.isNotEmpty)
          _buildTag(
            context,
            item.packingDescription!,
            Colors.grey[300]!,
            AppColors.greyColor,
          ),
        if (item.base != null && item.base!.isNotEmpty) ...[
          const SizedBox(width: 2),
          _buildTag(
            context,
            item.base!,
            Colors.grey[300]!,
            AppColors.greyColor,
          ),
        ],
        if (item.color != null && item.color!.isNotEmpty) ...[
          const SizedBox(width: 2),
          _buildTag(
            context,
            item.color!,
            _parseColorFromRGB(item.rGB),
            Colors.white,
          ),
        ],
      ],
    );
  }

  Widget _buildTag(
    BuildContext context,
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return FittedBox(
      child: Container(
        height: 20,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(color: textColor, fontSize: 10),
        ),
      ),
    );
  }

  Color _parseColorFromRGB(String? rgbString) {
    if (rgbString == null || rgbString.isEmpty) {
      return Colors.grey;
    }

    try {
      final rgbParts = rgbString.split(',');
      if (rgbParts.length >= 3) {
        return Color.fromRGBO(
          int.tryParse(rgbParts[0].trim()) ?? 0,
          int.tryParse(rgbParts[1].trim()) ?? 0,
          int.tryParse(rgbParts[2].trim()) ?? 0,
          1.0,
        );
      }
    } catch (e) {
      // ignore
    }
    return Colors.grey;
  }
}

/// Inline quantity controls with tap-to-edit functionality
class _QuantityControls extends StatefulWidget {
  final ProductItem item;

  const _QuantityControls({required this.item});

  @override
  State<_QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<_QuantityControls> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  late double _lastQuantity;

  @override
  void initState() {
    super.initState();
    _lastQuantity = widget.item.quantity ?? 0;
    _controller = TextEditingController(text: _formatQuantity(_lastQuantity));

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _saveQuantity();
      }
    });
  }

  @override
  void didUpdateWidget(_QuantityControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.quantity != widget.item.quantity && !_isEditing) {
      _lastQuantity = widget.item.quantity ?? 0;
      _controller.text = _formatQuantity(_lastQuantity);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatQuantity(double qty) {
    if (qty == qty.roundToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toString();
  }

  void _saveQuantity() {
    if (!mounted) return;

    setState(() => _isEditing = false);

    double? newQty = double.tryParse(_controller.text);
    if (newQty != null && newQty >= 0 && newQty <= 10000) {
      _lastQuantity = newQty;
      if (widget.item.itemID != null) {
        context.read<ProductsCubit>().updateCartItemQuantity(
          widget.item.itemID!,
          newQty,
        );
      }
    } else {
      _controller.text = _formatQuantity(_lastQuantity);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildWeightDisplay(),
        _buildPriceDisplay(),
        _buildQuantityRow(),
      ],
    );
  }

  Widget _buildWeightDisplay() {
    final weight = widget.item.wieght ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 5),
        Text(
          AppFunctions.formatNumber(weight),
          style: const TextStyle(
            fontSize: 14,
            height: 1,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        _label('كجم'),
      ],
    );
  }

  Widget _buildPriceDisplay() {
    final price = widget.item.amount ?? 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 5),
        Text(
          AppFunctions.formatNumber(price),
          style: const TextStyle(
            fontSize: 14,
            height: 1,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        _label('جنيه'),
      ],
    );
  }

  SizedBox _label(String title) {
    return SizedBox(
      width: 40,
      child: Text(
        title,
        textAlign: TextAlign.end,
        style: const TextStyle(
          color: AppColors.greyColor,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildQuantityRow() {
    final unitType = widget.item.sellingUM == "BX" ? "كرتونة" : 'عبوة';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [_buildQuantityEditor(), _label(unitType)],
    );
  }

  Widget _buildQuantityEditor() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = true;
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.text.length,
          );
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isEditing ? AppColors.primaryColor : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        width: 50,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: _isEditing
            ? TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: _handleQuantityChange,
                onFieldSubmitted: (_) => _saveQuantity(),
                onEditingComplete: _saveQuantity,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Center(
                child: Text(
                  _formatQuantity(widget.item.quantity ?? 0),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  void _handleQuantityChange(String value) {
    int? newValue = int.tryParse(value);
    if (newValue != null && newValue > 10000) {
      _controller.text = '10000';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }
}
