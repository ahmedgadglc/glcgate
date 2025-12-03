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

class _AnimatedCartListState extends State<AnimatedCartList>
    with SingleTickerProviderStateMixin {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<ProductItem> _items;
  late AnimationController _emptyStateController;
  late Animation<double> _emptyStateIconFadeAnimation;
  late Animation<double> _emptyStateIconScaleAnimation;
  late Animation<double> _emptyStateTitleFadeAnimation;
  late Animation<double> _emptyStateTitleScaleAnimation;
  late Animation<double> _emptyStateSubtitleFadeAnimation;
  late Animation<double> _emptyStateSubtitleScaleAnimation;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _emptyStateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Icon fade animation
    _emptyStateIconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Icon scale animation
    _emptyStateIconScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Title fade animation
    _emptyStateTitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Title scale animation
    _emptyStateTitleScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Subtitle fade animation
    _emptyStateSubtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Subtitle scale animation
    _emptyStateSubtitleScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _emptyStateController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Start animation if empty on init
    if (_items.isEmpty) {
      _emptyStateController.forward();
    }
  }

  @override
  void dispose() {
    _emptyStateController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCartList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle clearing all items
    if (widget.items.isEmpty && oldWidget.items.isNotEmpty) {
      _removeAllItems(oldWidget.items).then((_) {
        // Start empty state animation after all items are removed
        if (mounted && _items.isEmpty) {
          _emptyStateController.reset();
          _emptyStateController.forward();
        }
      });
      return;
    }

    // Handle transition from empty to having items
    if (widget.items.isNotEmpty && oldWidget.items.isEmpty) {
      _emptyStateController.reverse();
    }

    // Create maps for efficient lookup
    final oldItemsMap = {
      for (ProductItem item in oldWidget.items) item.itemID: item,
    };
    final newItemsMap = {
      for (ProductItem item in widget.items) item.itemID: item,
    };

    // Handle removed items
    for (ProductItem oldItem in oldWidget.items) {
      if (!newItemsMap.containsKey(oldItem.itemID)) {
        final index = _items.indexWhere(
          (item) => item.itemID == oldItem.itemID,
        );
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
        final index = _items.indexWhere(
          (item) => item.itemID == newItem.itemID,
        );
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
    final lastIndex = oldItems.length > 0 ? oldItems.length - 1 : 0;
    // Calculate total time: delay for last item + animation duration
    final totalDelay = (lastIndex * 50) + 300;

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

    // Wait for all animations to complete
    await Future.delayed(Duration(milliseconds: totalDelay));
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
      return const Center(child: CircularProgressIndicator());
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
          // Animated icon with fade and scale
          ScaleTransition(
            scale: _emptyStateIconScaleAnimation,
            child: FadeTransition(
              opacity: _emptyStateIconFadeAnimation,
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 100,
                color: AppColors.grey200,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Animated title with fade and scale
          ScaleTransition(
            scale: _emptyStateTitleScaleAnimation,
            child: FadeTransition(
              opacity: _emptyStateTitleFadeAnimation,
              child: Text(
                'لا توجد عناصر في السلة',
                style: TextStyle(fontSize: 20, color: AppColors.greyColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Animated subtitle with fade and scale
          ScaleTransition(
            scale: _emptyStateSubtitleScaleAnimation,
            child: FadeTransition(
              opacity: _emptyStateSubtitleFadeAnimation,
              child: Text(
                'أضف بعض المنتجات لتراها هنا',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.greyColor.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
