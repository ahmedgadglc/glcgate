class ProductItem {
  int? itemID;
  String? itemCode;
  int? productID;
  String? eRPItemDescription;
  int? packingTypeID;
  String? sellingUM;
  int? conversion;
  int? grossWeight;
  int? itemCategory1;
  int? itemCategory2;
  String? base;
  String? color;
  String? rGB;
  int? inActive;
  int? isCustom;
  String? itemURL;
  String? productDescription;
  String? packingDescription;
  String? itemCategoryDescription1;
  String? itemCategoryDescription2;
  String? itemType;
  double? quantity; // Added quantity field
  double? wieght;
  double? amount;
  bool? isAdded;

  ProductItem({
    this.itemID,
    this.itemCode,
    this.productID,
    this.eRPItemDescription,
    this.packingTypeID,
    this.sellingUM,
    this.conversion,
    this.grossWeight,
    this.itemCategory1,
    this.itemCategory2,
    this.base,
    this.color,
    this.rGB,
    this.inActive,
    this.isCustom,
    this.itemURL,
    this.productDescription,
    this.packingDescription,
    this.itemCategoryDescription1,
    this.itemCategoryDescription2,
    this.itemType,
    this.quantity, // Added to constructor
    this.wieght,
    this.amount,
    this.isAdded = false,
  });

  ProductItem.fromJson(Map<String, dynamic> json) {
    itemID = json['ItemID'];
    itemCode = json['ItemCode'];
    productID = json['ProductID'];
    eRPItemDescription = json['ERPItemDescription'];
    packingTypeID = json['PackingTypeID'];
    sellingUM = json['SellingUM'];
    conversion = json['Conversion'];
    grossWeight = json['GrossWeight'];
    itemCategory1 = json['ItemCategory1'];
    itemCategory2 = json['ItemCategory2'];
    base = json['Base'];
    color = json['Color'];
    rGB = json['RGB'];
    inActive = json['InActive'];
    isCustom = json['IsCustom'];
    itemURL = json['ItemURL'];
    productDescription = json['ProductDescription'];
    packingDescription = json['PackingDescription'];
    itemCategoryDescription1 = json['ItemCategoryDescription1'];
    itemCategoryDescription2 = json['ItemCategoryDescription2'];
    itemType = json['ItemType'];
    quantity = json['Quantity']; // Added to fromJson
    wieght = json['Wieght'];
    amount = json['Amount'];
    isAdded = json['IsAdded'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ItemID'] = itemID;
    data['ItemCode'] = itemCode;
    data['ProductID'] = productID;
    data['ERPItemDescription'] = eRPItemDescription;
    data['PackingTypeID'] = packingTypeID;
    data['SellingUM'] = sellingUM;
    data['Conversion'] = conversion;
    data['GrossWeight'] = grossWeight;
    data['ItemCategory1'] = itemCategory1;
    data['ItemCategory2'] = itemCategory2;
    data['Base'] = base;
    data['Color'] = color;
    data['RGB'] = rGB;
    data['InActive'] = inActive;
    data['IsCustom'] = isCustom;
    data['ItemURL'] = itemURL;
    data['ProductDescription'] = productDescription;
    data['PackingDescription'] = packingDescription;
    data['ItemCategoryDescription1'] = itemCategoryDescription1;
    data['ItemCategoryDescription2'] = itemCategoryDescription2;
    data['ItemType'] = itemType;
    data['Quantity'] = quantity; // Added to toJson
    data['Wieght'] = wieght;
    data['Amount'] = amount;
    data['IsAdded'] = isAdded;
    return data;
  }

  ProductItem copyWith({
    int? itemID,
    String? itemCode,
    int? productID,
    String? eRPItemDescription,
    int? packingTypeID,
    String? sellingUM,
    int? conversion,
    int? grossWeight,
    int? itemCategory1,
    int? itemCategory2,
    String? base,
    String? color,
    String? rGB,
    int? inActive,
    int? isCustom,
    String? itemURL,
    String? productDescription,
    String? packingDescription,
    String? itemCategoryDescription1,
    String? itemCategoryDescription2,
    String? itemType,
    double? quantity,
    double? wieght,
    double? amount,
    bool? isAdded,
  }) {
    return ProductItem(
      itemID: itemID ?? this.itemID,
      itemCode: itemCode ?? this.itemCode,
      productID: productID ?? this.productID,
      eRPItemDescription: eRPItemDescription ?? this.eRPItemDescription,
      packingTypeID: packingTypeID ?? this.packingTypeID,
      sellingUM: sellingUM ?? this.sellingUM,
      conversion: conversion ?? this.conversion,
      grossWeight: grossWeight ?? this.grossWeight,
      itemCategory1: itemCategory1 ?? this.itemCategory1,
      itemCategory2: itemCategory2 ?? this.itemCategory2,
      base: base ?? this.base,
      color: color ?? this.color,
      rGB: rGB ?? this.rGB,
      inActive: inActive ?? this.inActive,
      isCustom: isCustom ?? this.isCustom,
      itemURL: itemURL ?? this.itemURL,
      productDescription: productDescription ?? this.productDescription,
      packingDescription: packingDescription ?? this.packingDescription,
      itemCategoryDescription1:
          itemCategoryDescription1 ?? this.itemCategoryDescription1,
      itemCategoryDescription2:
          itemCategoryDescription2 ?? this.itemCategoryDescription2,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      wieght: wieght ?? this.wieght,
      amount: amount ?? this.amount,
      isAdded: isAdded ?? this.isAdded,
    );
  }

  void calculateWeight() {
    wieght = ((grossWeight ?? 0) * (quantity ?? 0) * (conversion ?? 1))
        .toDouble();
  }

  /// Calculate amount based on quantity
  void calculateAmount() {
    amount = (conversion ?? 0) * (quantity ?? 0);
  }

  /// Get unit type display text
  String get unitTypeDisplay => sellingUM == "BX" ? "كرتونة" : "عبوة";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductItem &&
          runtimeType == other.runtimeType &&
          itemID == other.itemID;

  @override
  int get hashCode => itemID.hashCode;
}
