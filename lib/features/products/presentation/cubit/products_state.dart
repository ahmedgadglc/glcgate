part of 'products_cubit.dart';

class ProductsState {
  final List<ProductItem> items;
  final List<ProductItem> cartItems;
  final List<String> categories1;
  final List<String> categories2;
  final List<String> itemMainDescriptionList;
  final List<String> packTypeList;
  final List<String> baseList;
  final List<String> colorList;

  final ProductItem? selectedItemMainDes;

  final String? selectedCategory1;
  final String? selectedCategory2;
  final String? selectedItemMainDescription;
  final String? selectedPackType;
  final String? selectedBase;
  final String? selectedColor;

  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;
  final bool isSearching;
  final bool viewCart;

  final double totalAmount;
  final double gateTotalAmount;
  final double totalTax;
  final double totalWeight;

  final String? note;

  ProductsState({
    required this.items,
    required this.cartItems,
    required this.categories1,
    required this.categories2,
    required this.itemMainDescriptionList,
    required this.packTypeList,
    required this.baseList,
    required this.colorList,
    this.selectedItemMainDes,
    this.selectedCategory1,
    this.selectedCategory2,
    this.selectedItemMainDescription,
    this.selectedPackType,
    this.selectedBase,
    this.selectedColor,
    this.searchQuery = '',
    required this.isLoading,
    this.errorMessage,
    this.isSearching = false,
    this.viewCart = false,
    this.totalAmount = 0,
    this.gateTotalAmount = 0,
    this.totalTax = 0,
    this.totalWeight = 0,
    this.note,
  });

  factory ProductsState.initial() => ProductsState(
    items: [],
    cartItems: [],
    categories1: [],
    categories2: [],
    itemMainDescriptionList: [],
    packTypeList: [],
    baseList: [],
    colorList: [],
    selectedCategory1: 'الكل',
    selectedCategory2: null,
    selectedItemMainDes: null,
    selectedPackType: null,
    selectedBase: null,
    selectedColor: null,
    searchQuery: '',
    isLoading: false,
    errorMessage: null,
    isSearching: false,
    viewCart: false,
    totalAmount: 0,
    gateTotalAmount: 0,
    totalTax: 0,
    totalWeight: 0,
    note: '',
  );

  // For backwards compatibility
  List<String> get categories => categories1;

  ProductsState copyWith({
    List<ProductItem>? items,
    List<ProductItem>? cartItems,
    List<String>? categories1,
    List<String>? categories2,
    List<String>? itemMainDescriptionList,
    List<String>? packTypeList,
    List<String>? baseList,
    List<String>? colorList,
    ProductItem? selectedItemMainDes,
    bool clearSelectedItem = false,
    String? selectedCategory1,
    String? selectedCategory2,
    String? selectedItemMainDescription,
    String? selectedPackType,
    bool clearPackType = false,
    String? selectedBase,
    bool clearBase = false,
    String? selectedColor,
    bool clearColor = false,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool? isSearching,
    bool? viewCart,
    double? totalAmount,
    double? gateTotalAmount,
    double? totalTax,
    double? totalWeight,
    String? note,
  }) {
    return ProductsState(
      items: items ?? this.items,
      cartItems: cartItems ?? this.cartItems,
      categories1: categories1 ?? this.categories1,
      categories2: categories2 ?? this.categories2,
      itemMainDescriptionList:
          itemMainDescriptionList ?? this.itemMainDescriptionList,
      packTypeList: packTypeList ?? this.packTypeList,
      baseList: baseList ?? this.baseList,
      colorList: colorList ?? this.colorList,
      selectedItemMainDes: clearSelectedItem
          ? null
          : (selectedItemMainDes ?? this.selectedItemMainDes),
      selectedCategory1: selectedCategory1 ?? this.selectedCategory1,
      selectedCategory2: selectedCategory2 ?? this.selectedCategory2,
      selectedItemMainDescription:
          selectedItemMainDescription ?? this.selectedItemMainDescription,
      selectedPackType: clearPackType
          ? null
          : (selectedPackType ?? this.selectedPackType),
      selectedBase: clearBase ? null : (selectedBase ?? this.selectedBase),
      selectedColor: clearColor ? null : (selectedColor ?? this.selectedColor),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSearching: isSearching ?? this.isSearching,
      viewCart: viewCart ?? this.viewCart,
      totalAmount: totalAmount ?? this.totalAmount,
      gateTotalAmount: gateTotalAmount ?? this.gateTotalAmount,
      totalTax: totalTax ?? this.totalTax,
      totalWeight: totalWeight ?? this.totalWeight,
      note: note ?? this.note,
    );
  }
}

enum CategoryFilterType { category1, category2 }

enum ProductFilterType { packType, base, color }
