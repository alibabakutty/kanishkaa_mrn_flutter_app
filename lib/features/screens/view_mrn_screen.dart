import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/model/order_item_model.dart';
import 'package:intl/intl.dart';

class ViewMrnScreen extends StatefulWidget {
  final MrnModel initialItems;
  final String? orderNumber;

  const ViewMrnScreen({
    super.key,
    required this.initialItems,
    required this.orderNumber,
  });

  @override
  State<ViewMrnScreen> createState() => _ViewMrnScreenState();
}

class _ViewMrnScreenState extends State<ViewMrnScreen> {
  late List<OrderItemModel> _orderItems;

  @override
  void initState() {
    super.initState();
    _orderItems = List<OrderItemModel>.from(widget.initialItems.orderItems);
  }

  // Resolver for Company display code
  String _getCompanyDisplayName() {
    final companyEnum = widget.initialItems.mrnOrderCompany;
    switch (companyEnum) {
      case MrnOrderCompany.KANISHKAA_CIVIL_ENGINEERING_PRIVATE_LIMITED:
        return "KCE";
      case MrnOrderCompany.KANISHKAA_FOUNDATION:
        return "KF";
      case MrnOrderCompany.SHREE_VRIKSHAH_HOMES:
        return "SVH";
      case MrnOrderCompany.SHREE_VRIKSHAH_HOMES_LLP:
        return "SVH_LLP";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        // Single compact row containing: Order Title, Order No, Company, and Date
        title: Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Row(
            children: [
              // 1. Order Title & Number
              Expanded(
                child: Text(
                  "Order: ${widget.orderNumber ?? ''}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // 2. Selected Company Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C685B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF0C685B).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getCompanyDisplayName(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0C685B),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 3. Date Stamp
              Text(
                DateFormat('dd-MM-yyyy').format(widget.initialItems.orderDate),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER DATA CARD (Site, Executive Name & Status) ---
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Site: ${widget.initialItems.siteName.isEmpty ? "-" : widget.initialItems.siteName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Site Engg. Name: ${widget.initialItems.executiveName ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: Text(
                    widget.initialItems.tallyStatus.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // --- PRODUCT ITEMS HEADER ---
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Order Items",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ),

          // --- READ-ONLY TABLE ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(35.0),
                  1: FlexColumnWidth(3),
                  2: FixedColumnWidth(55.0),
                  3: FixedColumnWidth(60.0),
                },
                border: TableBorder.all(
                  color: Colors.grey[300]!,
                  width: 1,
                  style: BorderStyle.solid,
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blueGrey[200]),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'S.No',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 4,
                        ),
                        child: Text(
                          'Product Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'UOM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        child: Text(
                          'Qty',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  // Data Rows
                  ...List.generate(_orderItems.length, (index) {
                    final item = _orderItems[index];

                    return TableRow(
                      children: [
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                          child: Text(
                            item.stockItemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          child: Text(
                            item.uom,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 6.0,
                          ),
                          child: Text(
                            item.quantity.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // --- CLOSE ACTION ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.redAccent),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}