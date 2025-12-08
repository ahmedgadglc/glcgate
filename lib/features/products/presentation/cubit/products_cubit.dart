import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glcgate/core/network/api_service.dart';
import 'package:glcgate/core/services/storage_service.dart';
import 'package:glcgate/features/products/data/models/product_item.dart';
import 'package:glcgate/features/products/data/repositories/products_repository.dart';

part 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsState.initial());

  final ProductsRepository _repository = ProductsRepository();

  // GlobalKey for cart icon to track position for fly-to-cart animation
  GlobalKey? _cartIconKey;

  /// Set the cart icon key for animation tracking
  void setCartIconKey(GlobalKey key) {
    _cartIconKey = key;
  }

  /// Get the cart icon key
  GlobalKey? get cartIconKey => _cartIconKey;

  Future<void> fetchProducts([int versionNo = 0]) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final items = await _repository.fetchProducts(versionNo);
      final categories1 = _extractUniqueCategories1(items);

      // Load cart items from storage
      final cartItems = await StorageService.getCartList();

      emit(
        state.copyWith(
          items: items,
          cartItems: cartItems,
          categories1: categories1,
          categories2: [],
          selectedCategory1: 'الكل',
          selectedCategory2: null,
          isLoading: false,
        ),
      );

      _calculateTotals();
    } on ApiException catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, errorMessage: 'حدث خطأ غير متوقع: $e'),
      );
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query, isSearching: query.isNotEmpty));
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: '', isSearching: false));
  }

  void setSelectedFilter(CategoryFilterType filterType, String value) {
    switch (filterType) {
      case CategoryFilterType.category1:
        _setSelectedCategory1(value);
        break;
      case CategoryFilterType.category2:
        _setSelectedCategory2(value);
        break;
    }
  }

  void _setSelectedCategory1(String category) {
    if (category == 'الكل') {
      emit(
        state.copyWith(
          selectedCategory1: 'الكل',
          categories2: [],
          selectedCategory2: null,
        ),
      );
      return;
    }

    // Get categories2 based on selected category1
    final List<String> categories2 = state.items
        .where((productItem) {
          return productItem.itemCategoryDescription1 == category;
        })
        .map((productItem) => productItem.itemCategoryDescription2 ?? '')
        .where((category2) => category2.isNotEmpty)
        .toSet()
        .toList();

    if (categories2.isNotEmpty) {
      categories2.insert(0, 'الكل');
    }

    emit(
      state.copyWith(
        selectedCategory1: category,
        categories2: categories2,
        selectedCategory2: categories2.isNotEmpty ? 'الكل' : null,
      ),
    );
  }

  void _setSelectedCategory2(String category) {
    emit(state.copyWith(selectedCategory2: category));
  }

  // For backwards compatibility
  void selectCategory(String? category) {
    if (category == null || category == 'الكل') {
      emit(
        state.copyWith(
          selectedCategory1: 'الكل',
          categories2: [],
          selectedCategory2: null,
        ),
      );
    } else {
      _setSelectedCategory1(category);
    }
  }

  // ==================== Product Selection Methods ====================

  /// Set selected item by productDescription - for AddProductCardView
  void setSelectproductDescription(ProductItem? item) {
    if (item == null) {
      emit(
        state.copyWith(
          clearSelectedItem: true,
          packTypeList: [],
          baseList: [],
          colorList: [],
          clearPackType: true,
          clearBase: true,
          clearColor: true,
        ),
      );
      return;
    }

    // Get packing types for this item
    final packTypes = getPackingTypes(item.productDescription);

    emit(
      state.copyWith(
        selectedItemMainDes: item.copyWith(quantity: 1),
        packTypeList: packTypes,
        baseList: [],
        colorList: [],
        selectedPackType: packTypes.isNotEmpty ? packTypes.first : null,
        clearBase: true,
        clearColor: true,
      ),
    );

    // If only one packing type, auto-select and get bases
    if (packTypes.length == 1) {
      setProductFilter(ProductFilterType.packType, packTypes.first);
    }
  }

  /// Set product filter (packType, base, color)
  void setProductFilter(ProductFilterType filterType, String value) {
    switch (filterType) {
      case ProductFilterType.packType:
        _setSelectedPackType(value);
        break;
      case ProductFilterType.base:
        _setSelectedBase(value);
        break;
      case ProductFilterType.color:
        _setSelectedColor(value);
        break;
    }
  }

  void _setSelectedPackType(String packType) {
    if (state.selectedItemMainDes == null) return;

    // Get bases for this packing type
    final bases = getBaseTypes(
      state.selectedItemMainDes!.productDescription,
      packType,
    );

    emit(
      state.copyWith(
        selectedPackType: packType,
        baseList: bases,
        colorList: [],
        selectedBase: bases.isNotEmpty ? bases.first : null,
        clearColor: true,
      ),
    );

    // If only one base, auto-select and get colors
    if (bases.length == 1) {
      _setSelectedBase(bases.first);
    } else if (bases.isEmpty) {
      // No bases, check for colors directly
      final colors = getColorsTypes(
        state.selectedItemMainDes!.productDescription,
        packType,
        null,
      );
      if (colors.isNotEmpty) {
        emit(state.copyWith(colorList: colors, selectedColor: colors.first));
        // Update selected item with the actual product
        _updateSelectedItemFromFilters();
      } else {
        // No bases and no colors - update selected item directly
        _updateSelectedItemFromFilters();
      }
    }
  }

  void _setSelectedBase(String base) {
    if (state.selectedItemMainDes == null) return;

    // Get colors for this base
    final colors = getColorsTypes(
      state.selectedItemMainDes!.productDescription,
      state.selectedPackType,
      base,
    );

    emit(
      state.copyWith(
        selectedBase: base,
        colorList: colors,
        selectedColor: colors.isNotEmpty ? colors.first : null,
      ),
    );

    // If only one color, auto-select
    if (colors.length == 1) {
      emit(state.copyWith(selectedColor: colors.first));
      // Update selected item with the actual product
      _updateSelectedItemFromFilters();
    } else if (colors.isEmpty) {
      // No colors - update selected item directly
      _updateSelectedItemFromFilters();
    }
  }

  void _setSelectedColor(String color) {
    emit(state.copyWith(selectedColor: color));
    // Update selected item with the actual product
    _updateSelectedItemFromFilters();
  }

  /// Update selectedItemMainDes with the actual product matching current filters
  void _updateSelectedItemFromFilters() {
    final matchingProduct = getSelectedProduct();
    if (matchingProduct != null) {
      // Preserve quantity from current selection
      final currentQuantity = state.selectedItemMainDes?.quantity ?? 1;
      final updatedItem = matchingProduct.copyWith(quantity: currentQuantity);
      updatedItem.calculateWeight();
      updatedItem.calculateAmount();
      emit(state.copyWith(selectedItemMainDes: updatedItem));
    }
  }

  /// Get packing types for productDescription
  List<String> getPackingTypes(String? productDescription) {
    if (productDescription == null) return [];

    return state.items
        .where((item) => item.productDescription == productDescription)
        .map((item) => item.packingDescription ?? '')
        .where((p) => p.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Get base types for productDescription and packingType
  List<String> getBaseTypes(String? productDescription, String? packingType) {
    if (productDescription == null) return [];

    return state.items
        .where(
          (item) =>
              item.productDescription == productDescription &&
              (packingType == null || item.packingDescription == packingType),
        )
        .map((item) => item.base ?? '')
        .where((b) => b.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Get color types for productDescription, packingType, and base
  List<String> getColorsTypes(
    String? productDescription,
    String? packingType,
    String? base,
  ) {
    if (productDescription == null) return [];

    return state.items
        .where(
          (item) =>
              item.productDescription == productDescription &&
              (packingType == null || item.packingDescription == packingType) &&
              (base == null || base.isEmpty || item.base == base),
        )
        .map((item) => item.color ?? '')
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Get the selected ProductItem based on current filters
  ProductItem? getSelectedProduct() {
    if (state.selectedItemMainDes == null) return null;

    return state.items.firstWhereOrNull(
      (item) =>
          item.productDescription ==
              state.selectedItemMainDes!.productDescription &&
          (state.selectedPackType == null ||
              item.packingDescription == state.selectedPackType) &&
          (state.selectedBase == null ||
              state.selectedBase!.isEmpty ||
              item.base == state.selectedBase) &&
          (state.selectedColor == null ||
              state.selectedColor!.isEmpty ||
              item.color == state.selectedColor),
    );
  }

  /// Update quantity for selected item
  void updateSelectedQuantity(double quantity) {
    if (state.selectedItemMainDes == null) return;

    final updatedItem = state.selectedItemMainDes!.copyWith(quantity: quantity);
    updatedItem.calculateWeight();
    updatedItem.calculateAmount();

    emit(state.copyWith(selectedItemMainDes: updatedItem));
  }

  // ==================== Cart Methods ====================

  /// Add selected item to cart
  /// [keepSelection] - if true, keeps the selected item for adding more with different specs (mobile)
  Future<void> addToCart({bool keepSelection = false}) async {
    final selectedProduct = getSelectedProduct();
    if (selectedProduct == null || state.selectedItemMainDes == null) return;

    // Create cart item with selected quantity
    final cartItem = selectedProduct.copyWith(
      quantity: state.selectedItemMainDes!.quantity ?? 1,
      isAdded: true,
    );
    cartItem.calculateWeight();
    cartItem.calculateAmount();

    // Check if item already exists in cart
    final existingIndex = state.cartItems.indexWhere(
      (item) => item.itemID == cartItem.itemID,
    );

    List<ProductItem> updatedCart = List.from(state.cartItems);

    if (existingIndex != -1) {
      // Update existing item
      updatedCart[existingIndex] = cartItem;
    } else {
      // Add new item
      updatedCart.add(cartItem);
    }

    // Save to storage
    await StorageService.saveCartList(updatedCart);

    if (keepSelection) {
      // Keep selection for mobile - user may want to add same item with different specs
      // Reset quantity to 0 so the listener updates the controller (animated reset)
      final resetItem = state.selectedItemMainDes!.copyWith(quantity: 0);
      resetItem.calculateWeight();
      resetItem.calculateAmount();

      emit(
        state.copyWith(cartItems: updatedCart, selectedItemMainDes: resetItem),
      );
    } else {
      // Clear selection for desktop
      emit(
        state.copyWith(
          cartItems: updatedCart,
          clearSelectedItem: true,
          packTypeList: [],
          baseList: [],
          colorList: [],
          clearPackType: true,
          clearBase: true,
          clearColor: true,
        ),
      );
    }

    _calculateTotals();
  }

  /// Remove item from cart
  Future<void> removeFromCart(int itemID) async {
    final updatedCart = state.cartItems
        .where((item) => item.itemID != itemID)
        .toList();

    await StorageService.saveCartList(updatedCart);

    emit(state.copyWith(cartItems: updatedCart));
    _calculateTotals();
  }

  /// Update cart item quantity
  Future<void> updateCartItemQuantity(int itemID, double quantity) async {
    if (quantity <= 0) {
      await removeFromCart(itemID);
      return;
    }

    final updatedCart = state.cartItems.map((item) {
      if (item.itemID == itemID) {
        final updated = item.copyWith(quantity: quantity);
        updated.calculateWeight();
        updated.calculateAmount();
        return updated;
      }
      return item;
    }).toList();

    await StorageService.saveCartList(updatedCart);

    emit(state.copyWith(cartItems: updatedCart));
    _calculateTotals();
  }

  /// Clear all cart items
  Future<void> clearCart() async {
    await StorageService.saveCartList([]);
    emit(
      state.copyWith(
        cartItems: [],
        totalAmount: 0,
        gateTotalAmount: 0,
        totalWeight: 0,
        totalTax: 0,
      ),
    );
  }

  /// Set cart note
  void setNote(String note) {
    emit(state.copyWith(note: note));
  }

  /// Toggle cart view
  void toggleCartView() {
    emit(state.copyWith(viewCart: !state.viewCart));
  }

  /// Calculate cart totals
  void _calculateTotals() {
    double totalAmount = 0;
    double gateTotalAmount = 0;
    double totalWeight = 0;

    for (final item in state.cartItems) {
      totalAmount += item.amount ?? 0;
      gateTotalAmount += item.amount ?? 0;
      totalWeight += item.wieght ?? 0;
    }

    emit(
      state.copyWith(
        totalAmount: totalAmount,
        gateTotalAmount: gateTotalAmount,
        totalWeight: totalWeight,
        totalTax: 0, // TODO: Calculate tax if needed
      ),
    );
  }

  /// Refresh cart from storage
  Future<void> refreshCart() async {
    final cartItems = await StorageService.getCartList();
    emit(state.copyWith(cartItems: cartItems));
    _calculateTotals();
  }

  // ==================== Existing Helper Methods ====================

  List<String> _extractUniqueCategories1(List<ProductItem> items) {
    final categories = items
        .map((item) => item.itemCategoryDescription1)
        .where((cat) => cat != null && cat.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return ['الكل'] + categories;
  }

  List<ProductItem> get filteredItems {
    // First apply category1 filter
    List<ProductItem> filtered = state.items;

    if (state.selectedCategory1 != null && state.selectedCategory1 != 'الكل') {
      filtered = filtered.where((item) {
        return item.itemCategoryDescription1 == state.selectedCategory1;
      }).toList();
    }

    // Apply category2 filter if selected
    if (state.selectedCategory2 != null && state.selectedCategory2 != 'الكل') {
      filtered = filtered.where((item) {
        return item.itemCategoryDescription2 == state.selectedCategory2;
      }).toList();
    }

    // Then apply search filter
    if (state.searchQuery.isNotEmpty) {
      filtered = _performSearch(filtered, state.searchQuery);
    }

    // Group by productDescription to avoid duplicates
    final groupedData = groupBy(filtered, (ProductItem e) {
      return e.productDescription ?? '';
    });

    return groupedData.entries.map<ProductItem>((entry) {
      return entry.value.first;
    }).toList();
  }

  List<ProductItem> _performSearch(List<ProductItem> items, String query) {
    final searchTerms = query
        .toLowerCase()
        .trim()
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();

    if (searchTerms.isEmpty) return items;

    return items.where((item) {
      final searchableText = [
        item.productDescription?.toLowerCase() ?? '',
        item.productDescription?.toLowerCase() ?? '',
        item.itemCode?.toLowerCase() ?? '',
        item.packingDescription?.toLowerCase() ?? '',
        item.base?.toLowerCase() ?? '',
        item.color?.toLowerCase() ?? '',
        item.itemCategoryDescription1?.toLowerCase() ?? '',
        item.itemCategoryDescription2?.toLowerCase() ?? '',
      ].join(' ');

      return searchTerms.any((term) => searchableText.contains(term));
    }).toList();
  }

  Map<String, List<ProductItem>> get groupedByCategory {
    final grouped = groupBy(filteredItems, (item) {
      return item.itemCategoryDescription1 ?? 'غير مصنف';
    });

    // Sort categories
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }
}
