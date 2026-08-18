import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/model/order_item_model.dart';
import 'package:mobile_app/features/model/product_summary_model.dart';
import 'package:mobile_app/features/provider/mrn_provider.dart';
import 'package:mobile_app/features/provider/stock_provider.dart';
import 'package:mobile_app/features/widget/product_search_delegate.dart';
import 'package:provider/provider.dart';
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
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    // Clone list so mutations don't alter original state directly until saved
    _orderItems = List<OrderItemModel>.from(widget.initialItems.orderItems);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().fetchAllProductsSummery();
    });
  }

  double _calculateTotalAmount() {
    return _orderItems.fold(0.0, (sum, item) {
      final lineAmount = item.quantity * item.rate;
      final discountAmount = lineAmount * 5 / 100; // 6% Discount
      return sum + (lineAmount - discountAmount);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  Future<void> _handleUpdateOrder() async {
    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order must contain at least 1 product.')),
      );
      return;
    }
    setState(() {
      _isUpdating = true;
    });

    try {
      final double calculatedTotal = _calculateTotalAmount();

      final updatedOrder = widget.initialItems.copyWith(
        orderItems: _orderItems,
        totalAmt: calculatedTotal,
      );



      final success = await context.read<MrnProvider>().updateOrder(
        updatedOrder,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updatedOrder);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update order. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving order: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _openProductSearch() async {
    final stocks = context.read<StockProvider>().summary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (mounted) Navigator.pop(context);
    if (mounted) {
      final ProductSummaryModel? selectedProduct =
          await showSearch<ProductSummaryModel?>(
            context: context,
            delegate: ProductSearchDelegate(allProducts: stocks),
          );

      if (selectedProduct != null) {
        setState(() {
          _orderItems.add(
            OrderItemModel(
              stockItemName: selectedProduct.itemName,
              rate: selectedProduct.rate,
              uom: selectedProduct.uom,
              quantity: 1,
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bool isEditable = false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),

        title: Text(
          "View Order: ${widget.orderNumber ?? ''}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                DateFormat('dd-MM-yyyy').format(widget.initialItems.orderDate),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER DATA CARD ---
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
                        'Site Name: ${widget.initialItems.siteName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                        ),
                      ),

                      const SizedBox(height: 5),

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

          // --- PRODUCT ITEMS LIST& button ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Order Items",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                if (isEditable)
                  // ignore: dead_code
                  InkWell(
                    onTap: _openProductSearch,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add_rounded,
                            size: 16,
                            color: Color(0xFF4F46E5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Add Product",
                            style: TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
                  // --- 1. TABLE HEADER ---
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blueGrey[200]),
                    children: [
                      const Padding(
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
                      const Padding(
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 0),
                        child: Text(
                          'UOM',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const Padding(
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
                      if (isEditable)
                        // ignore: dead_code
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text(""),
                        ), // Empty cell for Delete Header
                    ],
                  ),

                  // --- 2. DYNAMIC DATA ROWS ---
                  ...List.generate(_orderItems.length, (index) {
                    final item = _orderItems[index];

                    return TableRow(
                      children: [
                        // 1. S.No
                        Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // 2. Product Name
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 5,
                          ),
                          child: Text(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            item.stockItemName,

                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),

                        // 3. UOM
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5,
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

                        // 4. Editable Qty Field
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 5.0,
                          ),
                          child: SizedBox(
                            child: Text(
                                    item.quantity.toStringAsFixed(0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),

                        // 5. Delete (X) Icon
                        if (isEditable)
                          // ignore: dead_code
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _removeItem(index),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 5.0,
                                horizontal: 8.0,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // --- BOTTOM SUMMARY & ACTION BUTTONS ---
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- CANCEL & UPDATE BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isUpdating
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Colors.redAccent),
                            backgroundColor: Colors.red.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Close",
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // ignore: dead_code
                      if (isEditable) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isUpdating ? null : _handleUpdateOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981), // Green
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isUpdating
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Update Order",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ],
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
