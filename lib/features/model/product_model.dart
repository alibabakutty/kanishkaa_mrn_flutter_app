
class ProductModel {
  final String itemCode;
  final String itemName;
  final String uom;
  final String hsn;
  final String gst;
  final double rate;
  
  ProductModel({
    required this.itemCode,
    required this.itemName,
    required this.uom,
    required this.hsn,
    required this.gst,
    required this.rate
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      itemCode: json['partNumber']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? '',
      uom: json['itemUom']?.toString() ?? '',
      rate: (json['itemRate'] as num?)?.toDouble() ?? 0.0,
      hsn: json['hsnCode']?.toString() ?? '',
      gst: json['gstPercentage']?.toString() ?? ''
      
    );
  }
}
