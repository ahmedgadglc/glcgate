import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/products/data/models/product_item.dart';
import 'cart_provider.dart';

/// State class for CartCubit
class CartState {
  final int cartCount;
  final List<ProductItem> cartItems;
  final bool isLoading;
  final double totalWeight;
  final double totalAmount;
  final double totalTax;
  final String? note;
  final int? selectedShipToID;
  final String? shipToName;
  final String? errorMessage;

  CartState({
    required this.cartCount,
    required this.cartItems,
    required this.isLoading,
    this.totalWeight = 0,
    this.totalAmount = 0,
    this.totalTax = 0,
    this.note,
    this.selectedShipToID,
    this.shipToName,
    this.errorMessage,
  });

  factory CartState.initial() => CartState(
    cartCount: 0,
    cartItems: [],
    isLoading: false,
    totalWeight: 0,
    totalAmount: 0,
    totalTax: 0,
  );

  double get grandTotal => totalAmount + totalTax;

  CartState copyWith({
    int? cartCount,
    List<ProductItem>? cartItems,
    bool? isLoading,
    double? totalWeight,
    double? totalAmount,
    double? totalTax,
    String? note,
    int? selectedShipToID,
    String? shipToName,
    String? errorMessage,
  }) {
    return CartState(
      cartCount: cartCount ?? this.cartCount,
      cartItems: cartItems ?? this.cartItems,
      isLoading: isLoading ?? this.isLoading,
      totalWeight: totalWeight ?? this.totalWeight,
      totalAmount: totalAmount ?? this.totalAmount,
      totalTax: totalTax ?? this.totalTax,
      note: note ?? this.note,
      selectedShipToID: selectedShipToID ?? this.selectedShipToID,
      shipToName: shipToName ?? this.shipToName,
      errorMessage: errorMessage,
    );
  }
}

/// BLoC version for cart management
class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.initial());

  final CartProvider _cartProvider = CartProvider();

  /// Initialize cart from storage
  Future<void> initializeCart() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _cartProvider.initializeCart();
      _syncStateWithProvider();
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'فشل في تحميل السلة: $e',
        ),
      );
    }
  }

  /// Add item to cart
  Future<void> addToCart(ProductItem item, {double quantity = 1}) async {
    await _cartProvider.addToCart(item, quantity: quantity);
    _syncStateWithProvider();
  }

  /// Update item quantity
  Future<void> updateQuantity(int itemID, double quantity) async {
    await _cartProvider.updateQuantity(itemID, quantity);
    _syncStateWithProvider();
  }

  /// Increment item quantity
  Future<void> incrementQuantity(int itemID) async {
    final currentQty = _cartProvider.getItemQuantity(itemID);
    await _cartProvider.updateQuantity(itemID, currentQty + 1);
    _syncStateWithProvider();
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(int itemID) async {
    final currentQty = _cartProvider.getItemQuantity(itemID);
    if (currentQty > 1) {
      await _cartProvider.updateQuantity(itemID, currentQty - 1);
    } else {
      await removeFromCart(itemID);
    }
    _syncStateWithProvider();
  }

  /// Remove item from cart
  Future<void> removeFromCart(int itemID) async {
    await _cartProvider.removeFromCart(itemID);
    _syncStateWithProvider();
  }

  /// Clear cart
  Future<void> clearCart() async {
    await _cartProvider.clearCart();
    _syncStateWithProvider();
  }

  /// Update note
  Future<void> updateNote(String note) async {
    await _cartProvider.updateNote(note);
    _syncStateWithProvider();
  }

  /// Update shipping address
  Future<void> updateShipTo(int? shipToID, String? shipToName) async {
    await _cartProvider.updateShipTo(shipToID, shipToName);
    _syncStateWithProvider();
  }

  /// Check if item is in cart
  bool isInCart(int? itemID) {
    return _cartProvider.isInCart(itemID);
  }

  /// Get item quantity in cart
  double getItemQuantity(int? itemID) {
    return _cartProvider.getItemQuantity(itemID);
  }

  /// Sync state with provider
  void _syncStateWithProvider() {
    emit(
      state.copyWith(
        isLoading: false,
        cartCount: _cartProvider.cartCount,
        cartItems: List<ProductItem>.from(_cartProvider.cartItems),
        totalWeight: _cartProvider.totalWeight,
        totalAmount: _cartProvider.totalAmount,
        totalTax: _cartProvider.totalTax,
        note: _cartProvider.note,
        selectedShipToID: _cartProvider.selectedShipToID,
        shipToName: _cartProvider.shipToName,
      ),
    );
  }

  /// Refresh from storage
  Future<void> refreshFromStorage() async {
    await _cartProvider.refreshFromStorage();
    _syncStateWithProvider();
  }
}
