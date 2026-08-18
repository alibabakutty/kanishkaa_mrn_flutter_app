
class AllMrnModel {
  final String orderNumber;
  final String siteName;
  final String executiveName;
  final String orderDate;
  final double totalAmt;
  final String status;
  final String tallyStatus;
  final int id;
  final String stockItemName;
  final double stockPrice;
  final String uom;
  final double quantity;

  AllMrnModel({
    required this.orderNumber,
    required this.siteName,
    required this.executiveName,
    required this.orderDate,
    required this.id,
    required this.stockItemName,
    required this.stockPrice,
    required this.uom,
    required this.quantity,
    required this.totalAmt,
    required this.status,
    required this.tallyStatus,
  });

  factory AllMrnModel.fromJson(Map<String, dynamic> json) {
    return AllMrnModel(
      orderNumber: json['orderNumber']?.toString() ?? '',
      siteName: json['siteName']?.toString() ?? '',
      executiveName: json['ExecutiveName']?.toString() ?? '',
      orderDate: json['orderDate']?.toString() ?? '',
      id: int.tryParse(json['id'].toString()) ?? 0,
      stockItemName: json['stockItemName']?.toString().trim() ?? '',
      stockPrice: double.tryParse(json['stockPrice'].toString()) ?? 0.0,
      uom: json['uom']?.toString() ?? '',
      quantity: double.tryParse(json['quantity'].toString()) ?? 0.0,
      totalAmt: double.tryParse(json['totalAmt'].toString()) ?? 0.0,
      status: 'PENDING',
      tallyStatus: json['tallyStatus']?.toString() ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderNumber': orderNumber,
      'customerName': siteName,
      'ExecutiveName': executiveName,
      'orderDate': orderDate,
      'totalAmt': totalAmt,
      'status': status,
      'tallyStatus': tallyStatus,
      'id': id,
      'stockItemName': stockItemName,
      'stockPrice': stockPrice,
      'uom': uom,
      'quantity': quantity,
    };
  }
}