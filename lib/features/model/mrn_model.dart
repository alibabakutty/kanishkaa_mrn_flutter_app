import 'order_item_model.dart';

class MrnModel {
  final String? orderNumber;
  final String siteName;
  final String? executiveName;
  final String status;
  final String tallyStatus;

  // Nullable because backend can return null
  final double? totalQty;
  final String? totalUom;

  final double totalAmt;
  final DateTime orderDate;
  final List<OrderItemModel> orderItems;

  MrnModel({
    this.orderNumber,
    required this.siteName,
    required this.executiveName,
    required this.orderItems,
    required this.status,
    required this.totalQty,
    this.totalUom,
    required this.totalAmt,
    required this.orderDate,
    required this.tallyStatus,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (orderNumber != null) "orderNumber": orderNumber,
      "siteName": siteName,
      "executiveName": executiveName,
      "totalQty": totalQty,
      "totalUom": totalUom,
      "totalAmt": totalAmt,
      "status": status,
      "tallyStatus": tallyStatus,
      "orderItems": orderItems.map((item) => item.toJson()).toList(),
    };
  }

  factory MrnModel.fromJson(Map<String, dynamic> json) {
    return MrnModel(
      orderNumber: json['orderNumber']?.toString(),
      siteName: json['siteName'] ?? '',
      executiveName: json['executiveName'] ?? '',
      status: json['status'] ?? 'PENDING',
      tallyStatus: json['tallyStatus'] ?? '',

      // NULL is now allowed
      totalQty: (json['totalQty'] as num?)?.toDouble(),

      // NULL is now allowed
      totalUom: json['totalUom'] as String?,

      totalAmt: (json['totalAmt'] as num?)?.toDouble() ?? 0.0,

      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),

      orderItems: (json['orderItems'] as List? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }

  MrnModel copyWith({
    String? siteName,
    String? orderNumber,
    List<OrderItemModel>? orderItems,
    double? totalQty,
    String? totalUom,
    double? totalAmt,
    String? executiveName,
    String? status,
    String? tallyStatus,
    DateTime? orderDate,
  }) {
    return MrnModel(
      siteName: siteName ?? this.siteName,
      orderNumber: orderNumber ?? this.orderNumber,
      orderItems: orderItems ?? this.orderItems,
      totalQty: totalQty ?? this.totalQty,
      totalUom: totalUom ?? this.totalUom,
      totalAmt: totalAmt ?? this.totalAmt,
      executiveName: executiveName ?? this.executiveName,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      tallyStatus: tallyStatus ?? this.tallyStatus,
    );
  }
}