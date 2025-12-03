class ProductItem {
  int? iD;
  int? itemID;
  int? lineNumber;
  String? itemCode;
  String? itemMainDescription;
  String? itemDescription;
  String? eRPItemDescription;
  String? packingType;
  String? sellingUM;
  int? conversion;
  double? wieght;
  double? amount;
  double? grossWeight;
  int? itemCategory1;
  int? itemCategory2;
  int? uRLID;
  String? base;
  double? quantity;
  double? quantityOriginal;
  double? quantityConfirmed;
  bool isQuantityConfirmed;
  String? itemCategory1Description;
  String? itemCategory2Description;
  String? uRL;
  double? priceSellingUM;
  String? color;
  String? rGB;
  int? descriptionID;
  int? lineEchoOrderNo;
  double gateQuantityOriginal;
  double gateQuantityConfirmed;
  double? gateWieght;
  double? gateAmount;
  bool? isAdded;
  int? isNotOriginal;
  double? oiginalSubDealerQty;

  ProductItem({
    this.iD,
    this.itemID,
    this.lineNumber,
    this.itemCode,
    this.itemMainDescription,
    this.itemDescription,
    this.eRPItemDescription,
    this.packingType,
    this.quantityOriginal = 0,
    this.quantity = 0,
    this.quantityConfirmed = 1,
    this.isQuantityConfirmed = false,
    this.sellingUM,
    this.conversion,
    this.wieght,
    this.amount,
    this.grossWeight,
    this.itemCategory1,
    this.itemCategory2,
    this.uRLID,
    this.base,
    this.descriptionID,
    this.color,
    this.rGB,
    this.itemCategory1Description,
    this.itemCategory2Description = '',
    this.uRL,
    this.priceSellingUM,
    this.lineEchoOrderNo,
    this.gateQuantityOriginal = 0,
    this.gateQuantityConfirmed = 0,
    this.gateWieght = 0,
    this.gateAmount = 0,
    this.isAdded = false,
    this.isNotOriginal = 0,
    this.oiginalSubDealerQty,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      iD: json['ID'],
      lineNumber: json['LineNumber'],
      itemID: json['ItemID'],
      itemCode: json['ItemCode'],
      itemMainDescription: json['ItemMainDescription'],
      quantityOriginal:
          (json['OriginalOrderedQuantity'] as num?)?.toDouble() ?? 0,
      quantity: (json['OriginalOrderedQuantity'] as num?)?.toDouble() ?? 0,
      quantityConfirmed:
          (json['OriginalConfirmedQuantity'] as num?)?.toDouble() ?? 0,
      itemDescription: json['ItemDescription'],
      isQuantityConfirmed: json['IsQuantityConfirmed'] ?? false,
      eRPItemDescription: json['ERPItemDescription'],
      packingType: json['PackingType'],
      sellingUM: json['SellingUM'],
      conversion: json['Conversion'],
      wieght: (json['Wieght'] as num?)?.toDouble(),
      amount: (json['Amount'] as num?)?.toDouble(),
      grossWeight: (json['GrossWeight'] as num?)?.toDouble(),
      itemCategory1: json['ItemCategory1'],
      itemCategory2: json['ItemCategory2'],
      uRLID: json['URLID'],
      base: json['Base'],
      itemCategory1Description: json['ItemCategory1Description'],
      itemCategory2Description: json['ItemCategory2Description'] ?? '',
      uRL: json['URL'],
      priceSellingUM: (json['PriceSellingUM'] as num?)?.toDouble(),
      color: json['Color'],
      rGB: json['RGB'],
      descriptionID: json['DescriptionID'],
      lineEchoOrderNo: json['LineEchoOrderNo'],
      gateQuantityOriginal:
          (json['OriginalOrderedQuantity'] as num?)?.toDouble() ?? 0,
      gateQuantityConfirmed:
          (json['OriginalConfirmedQuantity'] as num?)?.toDouble() ?? 0,
      gateWieght: (json['Wieght'] as num?)?.toDouble() ?? 0,
      gateAmount: (json['Amount'] as num?)?.toDouble() ?? 0,
      isAdded: json['IsAdded'] ?? false,
      isNotOriginal: json['IsNotOriginal'] ?? 0,
      oiginalSubDealerQty: (json['OiginalSubDealerQty'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': iD,
      'ItemID': itemID,
      'LineNumber': lineNumber,
      'ItemCode': itemCode,
      'ItemMainDescription': itemMainDescription,
      'ItemDescription': itemDescription,
      'ERPItemDescription': eRPItemDescription,
      'PackingType': packingType,
      'IsQuantityConfirmed': isQuantityConfirmed,
      'SellingUM': sellingUM,
      'OriginalOrderedQuantity': quantity,
      'OriginalConfirmedQuantity': quantityConfirmed,
      'Conversion': conversion,
      'Wieght': wieght,
      'Amount': amount,
      'GrossWeight': grossWeight,
      'ItemCategory1': itemCategory1,
      'ItemCategory2': itemCategory2,
      'URLID': uRLID,
      'Base': base,
      'ItemCategory1Description': itemCategory1Description,
      'ItemCategory2Description': itemCategory2Description,
      'PriceSellingUM': priceSellingUM,
      'URL': uRL,
      'Quantity': quantity,
      'Color': color,
      'RGB': rGB,
      'DescriptionID': descriptionID,
      'LineEchoOrderNo': lineEchoOrderNo,
      'GateQuantityOriginal': gateQuantityOriginal,
      'GateQuantityConfirmed': gateQuantityConfirmed,
      'GateWieght': gateWieght,
      'GateAmount': gateAmount,
      'IsAdded': isAdded,
      'IsNotOriginal': isNotOriginal,
      'OiginalSubDealerQty': oiginalSubDealerQty,
    };
  }

  ProductItem copyWith({
    int? iD,
    int? itemID,
    int? lineNumber,
    String? itemCode,
    String? itemMainDescription,
    String? itemDescription,
    String? eRPItemDescription,
    String? packingType,
    String? sellingUM,
    int? conversion,
    double? wieght,
    double? amount,
    double? grossWeight,
    int? itemCategory1,
    int? itemCategory2,
    int? uRLID,
    String? base,
    double? quantity,
    double? quantityOriginal,
    double? quantityConfirmed,
    bool? isQuantityConfirmed,
    String? itemCategory1Description,
    String? itemCategory2Description,
    String? uRL,
    double? priceSellingUM,
    int? descriptionID,
    String? rGB,
    String? color,
    int? lineEchoOrderNo,
    double? gateQuantityOriginal,
    double? gateQuantityConfirmed,
    double? gateWieght,
    double? gateAmount,
    bool? isAdded,
    int? isNotOriginal,
    double? oiginalSubDealerQty,
  }) {
    return ProductItem(
      iD: iD ?? this.iD,
      itemID: itemID ?? this.itemID,
      lineNumber: lineNumber ?? this.lineNumber,
      itemCode: itemCode ?? this.itemCode,
      itemMainDescription: itemMainDescription ?? this.itemMainDescription,
      itemDescription: itemDescription ?? this.itemDescription,
      eRPItemDescription: eRPItemDescription ?? this.eRPItemDescription,
      packingType: packingType ?? this.packingType,
      sellingUM: sellingUM ?? this.sellingUM,
      conversion: conversion ?? this.conversion,
      wieght: wieght ?? this.wieght,
      amount: amount ?? this.amount,
      grossWeight: grossWeight ?? this.grossWeight,
      itemCategory1: itemCategory1 ?? this.itemCategory1,
      itemCategory2: itemCategory2 ?? this.itemCategory2,
      uRLID: uRLID ?? this.uRLID,
      base: base ?? this.base,
      quantity: quantity ?? this.quantity,
      quantityOriginal: quantityOriginal ?? this.quantityOriginal,
      quantityConfirmed: quantityConfirmed ?? this.quantityConfirmed,
      isQuantityConfirmed: isQuantityConfirmed ?? this.isQuantityConfirmed,
      itemCategory1Description:
          itemCategory1Description ?? this.itemCategory1Description,
      itemCategory2Description:
          itemCategory2Description ?? this.itemCategory2Description,
      uRL: uRL ?? this.uRL,
      priceSellingUM: priceSellingUM ?? this.priceSellingUM,
      color: color ?? this.color,
      descriptionID: descriptionID ?? this.descriptionID,
      rGB: rGB ?? this.rGB,
      lineEchoOrderNo: lineEchoOrderNo ?? this.lineEchoOrderNo,
      gateQuantityOriginal: gateQuantityOriginal ?? this.gateQuantityOriginal,
      gateQuantityConfirmed:
          gateQuantityConfirmed ?? this.gateQuantityConfirmed,
      gateWieght: gateWieght ?? this.gateWieght,
      gateAmount: gateAmount ?? this.gateAmount,
      isAdded: isAdded ?? this.isAdded,
      isNotOriginal: isNotOriginal ?? this.isNotOriginal,
      oiginalSubDealerQty: oiginalSubDealerQty ?? this.oiginalSubDealerQty,
    );
  }

  /// Calculate weight based on quantity
  void calculateWeight() {
    wieght = (grossWeight ?? 0) * (quantity ?? 0) * (conversion ?? 1);
  }

  /// Calculate amount based on quantity
  void calculateAmount() {
    amount = (priceSellingUM ?? 0) * (quantity ?? 0);
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
