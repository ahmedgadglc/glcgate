import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Quantity controls widget with increment/decrement buttons
class QuantityControls extends StatefulWidget {
  final double quantity;
  final ValueChanged<double> onQuantityChanged;
  final double minQuantity;
  final double maxQuantity;
  final bool showDeleteOnZero;
  final VoidCallback? onDelete;
  final bool compact;

  const QuantityControls({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    this.minQuantity = 0,
    this.maxQuantity = 10000,
    this.showDeleteOnZero = true,
    this.onDelete,
    this.compact = false,
  });

  @override
  State<QuantityControls> createState() => _QuantityControlsState();
}

class _QuantityControlsState extends State<QuantityControls> {
  late TextEditingController _controller;
  bool _isEditing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toStringAsFixed(0));
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(QuantityControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && !_isEditing) {
      _controller.text = widget.quantity.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _saveQuantity();
    }
  }

  void _saveQuantity() {
    setState(() => _isEditing = false);
    
    final newQty = double.tryParse(_controller.text) ?? widget.quantity;
    final clampedQty = newQty.clamp(widget.minQuantity, widget.maxQuantity);
    
    if (clampedQty != widget.quantity) {
      widget.onQuantityChanged(clampedQty);
    }
    _controller.text = clampedQty.toStringAsFixed(0);
  }

  void _increment() {
    final newQty = (widget.quantity + 1).clamp(widget.minQuantity, widget.maxQuantity);
    widget.onQuantityChanged(newQty);
  }

  void _decrement() {
    if (widget.quantity <= 1 && widget.showDeleteOnZero && widget.onDelete != null) {
      widget.onDelete!();
      return;
    }
    final newQty = (widget.quantity - 1).clamp(widget.minQuantity, widget.maxQuantity);
    widget.onQuantityChanged(newQty);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactLayout();
    }
    return _buildDefaultLayout();
  }

  Widget _buildDefaultLayout() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: widget.quantity <= 1 && widget.showDeleteOnZero
                ? Icons.delete_outline
                : Icons.remove,
            onTap: _decrement,
            color: widget.quantity <= 1 && widget.showDeleteOnZero
                ? AppColors.errorColor
                : AppColors.greyColor,
          ),
          _buildQuantityDisplay(),
          _buildButton(
            icon: Icons.add,
            onTap: widget.quantity < widget.maxQuantity ? _increment : null,
            color: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCompactButton(
          icon: widget.quantity <= 1 && widget.showDeleteOnZero
              ? Icons.delete_outline
              : Icons.remove,
          onTap: _decrement,
          color: widget.quantity <= 1 && widget.showDeleteOnZero
              ? AppColors.errorColor
              : AppColors.greyColor,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            widget.quantity.toStringAsFixed(0),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        _buildCompactButton(
          icon: Icons.add,
          onTap: widget.quantity < widget.maxQuantity ? _increment : null,
          color: AppColors.primaryColor,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onTap != null ? color : AppColors.grey200,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 16,
            color: onTap != null ? color : AppColors.grey200,
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityDisplay() {
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
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                onFieldSubmitted: (_) => _saveQuantity(),
                onEditingComplete: _saveQuantity,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                widget.quantity.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

/// Add to cart button - shows quantity controls if item is in cart
class AddToCartButton extends StatelessWidget {
  final bool isInCart;
  final double quantity;
  final VoidCallback onAddToCart;
  final ValueChanged<double> onQuantityChanged;
  final VoidCallback? onRemove;

  const AddToCartButton({
    super.key,
    required this.isInCart,
    required this.quantity,
    required this.onAddToCart,
    required this.onQuantityChanged,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (isInCart && quantity > 0) {
      return QuantityControls(
        quantity: quantity,
        onQuantityChanged: onQuantityChanged,
        onDelete: onRemove,
        compact: true,
      );
    }

    return Material(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onAddToCart,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_shopping_cart, size: 18, color: Colors.white),
              SizedBox(width: 4),
              Text(
                'إضافة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

