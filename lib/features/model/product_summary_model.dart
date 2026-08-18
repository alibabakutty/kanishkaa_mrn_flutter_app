class ProductSummaryModel {
  final int id;
  final String itemName;
  final String uom;
  final double rate;
  final String stockStatus;
  final String itemCode;

  ProductSummaryModel({
    required this.id,
    required this.itemName,
     required this.uom,
    required this.rate,
    required this.stockStatus,
    required this.itemCode,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json){
    return ProductSummaryModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        itemCode: json['itemCode']?.toString() ?? '',
        itemName: json['itemName']?.toString() ?? '',
        uom: json['uom']?.toString() ?? '',
        rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
        stockStatus: json['stockStatus']?.toString() ?? ''
    );
  }

}