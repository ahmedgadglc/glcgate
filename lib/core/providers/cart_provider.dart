import 'package:flutter/material.dart';

import '../../features/products/data/models/product_item.dart';
import '../services/storage_service.dart';

/// Cart Provider to manage cart count and cart items globally
class CartProvider extends ChangeNotifier {
  static final CartProvider _instance = CartProvider._internal();
  factory CartProvider() => _instance;
  CartProvider._internal();

  int _cartCount = 0;
  List<ProductItem> _cartItems = [];
  double _totalWeight = 0;
  double _totalAmount = 0;
  double _totalTax = 0;
  String? _note;
  int? _selectedShipToID;
  String? _shipToName;

  /// Getters
  int get cartCount => _cartCount;
  List<ProductItem> get cartItems => _cartItems;
  bool get hasItems => _cartCount > 0;
  double get totalWeight => _totalWeight;
  double get totalAmount => _totalAmount;
  double get totalTax => _totalTax;
  double get grandTotal => _totalAmount + _totalTax;
  String? get note => _note;
  int? get selectedShipToID => _selectedShipToID;
  String? get shipToName => _shipToName;

  /// Initialize cart from storage
  Future<void> initializeCart() async {
    _cartItems = await StorageService.getCartList();
    _cartCount = _cartItems.length;
    _note = await StorageService.getCartNote();
    _selectedShipToID = await StorageService.getShipToID();
    _shipToName = await StorageService.getShipToName();
    _calculateTotals();
    notifyListeners();
  }

  /// Update cart items and count
  Future<void> updateCart(List<ProductItem> items) async {
    _cartItems = items;
    _cartCount = items.length;
    await StorageService.setCartList(items);
    _calculateTotals();
    notifyListeners();
  }

  /// Add item to cart
  Future<void> addToCart(ProductItem item, {double quantity = 1}) async {
    final existingIndex = _cartItems.indexWhere(
      (cartItem) => cartItem.itemID == item.itemID,
    );

    if (existingIndex != -1) {
      final existingItem = _cartItems[existingIndex];
      final newQuantity = (existingItem.quantity ?? 0) + quantity;
      final updatedItem = existingItem.copyWith(quantity: newQuantity);
      updatedItem.calculateWeight();
      updatedItem.calculateAmount();
      _cartItems[existingIndex] = updatedItem;
    } else {
      final newItem = item.copyWith(quantity: quantity);
      newItem.calculateWeight();
      newItem.calculateAmount();
      _cartItems.add(newItem);
    }

    _cartCount = _cartItems.length;
    await StorageService.setCartList(_cartItems);
    _calculateTotals();
    notifyListeners();
  }

  /// Update item quantity in cart
  Future<void> updateQuantity(int itemID, double quantity) async {
    final index = _cartItems.indexWhere((item) => item.itemID == itemID);
    if (index != -1) {
      if (quantity <= 0) {
        await removeFromCart(itemID);
        return;
      }

      final updatedItem = _cartItems[index].copyWith(quantity: quantity);
      updatedItem.calculateWeight();
      updatedItem.calculateAmount();
      _cartItems[index] = updatedItem;

      await StorageService.setCartList(_cartItems);
      _calculateTotals();
      notifyListeners();
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(int itemID) async {
    _cartItems.removeWhere((item) => item.itemID == itemID);
    _cartCount = _cartItems.length;
    await StorageService.setCartList(_cartItems);
    _calculateTotals();
    notifyListeners();
  }

  /// Clear entire cart
  Future<void> clearCart() async {
    _cartItems.clear();
    _cartCount = 0;
    _totalWeight = 0;
    _totalAmount = 0;
    _totalTax = 0;
    _note = null;
    await StorageService.setCartList([]);
    await StorageService.setCartNote('');
    notifyListeners();
  }

  /// Update note
  Future<void> updateNote(String note) async {
    _note = note;
    await StorageService.setCartNote(note);
    notifyListeners();
  }

  /// Calculate totals
  void _calculateTotals() {
    _totalWeight = 0;
    _totalAmount = 0;

    for (final item in _cartItems) {
      _totalWeight += item.wieght ?? 0;
      _totalAmount += item.amount ?? 0;
    }

    // Tax calculation (14% VAT in Egypt)
    _totalTax = _totalAmount * 0.14;
  }

  /// Check if item is in cart
  bool isInCart(int? itemID) {
    if (itemID == null) return false;
    return _cartItems.any((item) => item.itemID == itemID);
  }

  /// Get item quantity in cart
  double getItemQuantity(int? itemID) {
    if (itemID == null) return 0;
    final item = _cartItems.firstWhere(
      (item) => item.itemID == itemID,
      orElse: () => ProductItem(),
    );
    return item.quantity ?? 0;
  }

  /// Refresh cart from storage
  Future<void> refreshFromStorage() async {
    await initializeCart();
  }
}

/// Extension to easily access CartProvider from BuildContext
extension CartProviderExtension on BuildContext {
  CartProvider get cartProvider => CartProvider();
}
