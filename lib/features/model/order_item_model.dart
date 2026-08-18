
class OrderItemModel {
  final String? partNumber;
  final String stockItemName;
  final double rate;
  final String uom;
  final double quantity;

  OrderItemModel({
    this.partNumber,
    required this.stockItemName,
    required this.rate,
    required this.uom,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      "partNumber": partNumber,
      "stockItemName": stockItemName,
      "rate": rate,
      "uom": uom,
      "quantity": quantity,
    };
  }

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      partNumber: json['partNumber']?.toString() ?? '',
      stockItemName: json['stockItemName']?.toString() ?? '',
      uom: json['uom']?.toString() ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  OrderItemModel copyWith({
    String? partNumber,
    String? stockItemName,
    double? quantity,
    double? rate,
    String? uom,
    String? stockCategory
  }) {
    return OrderItemModel(
      partNumber: partNumber ?? this.partNumber,
      stockItemName: stockItemName ?? this.stockItemName,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      uom: uom ?? this.uom
    );
  }
}