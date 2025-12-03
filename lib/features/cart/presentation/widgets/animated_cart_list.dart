import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../products/data/models/product_item.dart';
import 'cart_item_card.dart';

/// Animated cart list with insert/remove animations
class AnimatedCartList extends StatefulWidget {
  final List<ProductItem> items;
  final bool isLoading;

  const AnimatedCartList({
    super.key,
    required this.items,
    required this.isLoading,
  });

  @override
  State<AnimatedCartList> createState() => _AnimatedCartListState();
}

class _AnimatedCartListState extends State<AnimatedCartList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<ProductItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  void didUpdateWidget(AnimatedCartList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle clearing all items
    if (widget.items.isEmpty && oldWidget.items.isNotEmpty) {
      _removeAllItems(oldWidget.items);
      return;
    }

    // Create maps for efficient lookup
    final oldItemsMap = {
      for (ProductItem item in oldWidget.items) item.itemID: item
    };
    final newItemsMap = {
      for (ProductItem item in widget.items) item.itemID: item
    };

    // Handle removed items
    for (ProductItem oldItem in oldWidget.items) {
      if (!newItemsMap.containsKey(oldItem.itemID)) {
        final index =
            _items.indexWhere((item) => item.itemID == oldItem.itemID);
        if (index != -1) {
          _removeItem(index);
        }
      }
    }

    // Handle added items
    for (ProductItem newItem in widget.items) {
      if (!oldItemsMap.containsKey(newItem.itemID)) {
        _addItem(newItem);
      }
    }

    // Handle quantity updates
    for (ProductItem newItem in widget.items) {
      final oldItem = oldItemsMap[newItem.itemID];
      if (oldItem != null && oldItem.quantity != newItem.quantity) {
        final index =
            _items.indexWhere((item) => item.itemID == newItem.itemID);
        if (index != -1) {
          setState(() {
            _items[index] = newItem;
          });
        }
      }
    }
  }

  Future<void> _removeAllItems(List<ProductItem> oldItems) async {
    final indices = List.generate(oldItems.length, (index) => index).reversed;

    for (final index in indices) {
      if (index < _items.length) {
        final removedItem = _items[index];
        await Future.delayed(Duration(milliseconds: 50 * index), () {
          if (mounted && _listKey.currentState != null) {
            _listKey.currentState?.removeItem(
              index,
              (context, animation) => _buildRemovedItem(removedItem, animation),
              duration: const Duration(milliseconds: 300),
            );

            if (mounted && index < _items.length) {
              setState(() {
                _items.removeAt(index);
              });
            }
          }
        });
      }
    }
  }

  void _removeItem(int index) {
    if (index >= _items.length) return;

    final removedItem = _items[index];
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );
    _items.removeAt(index);
  }

  void _addItem(ProductItem item) {
    _items.add(item);
    _listKey.currentState?.insertItem(
      _items.length - 1,
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildRemovedItem(ProductItem item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: CartItemCard(item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_items.isEmpty) {
      return _buildEmptyState();
    }

    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.only(bottom: 80, top: 8),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        if (index >= _items.length) return const SizedBox.shrink();
        return SizeTransition(
          sizeFactor: animation,
          child: FadeTransition(
            opacity: animation,
            child: CartItemCard(item: _items[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.grey200,
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد عناصر في السلة',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.greyColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف بعض المنتجات لتراها هنا',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

