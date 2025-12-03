import '../../../features/products/data/models/product_item.dart';

class CartStates {
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

  CartStates({
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

  factory CartStates.initial() => CartStates(
    cartCount: 0,
    cartItems: [],
    isLoading: false,
    totalWeight: 0,
    totalAmount: 0,
    totalTax: 0,
  );

  double get grandTotal => totalAmount + totalTax;

  CartStates copyWith({
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
    return CartStates(
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
