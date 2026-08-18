import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/provider/auth_provider.dart';
import 'package:mobile_app/features/provider/mrn_provider.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final MrnModel orderData;

  const CheckoutScreen({super.key, required this.orderData});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  double get calculatedTotal {
    return widget.orderData.orderItems.fold(
      0,
      (sum, item) => sum + (item.rate * item.quantity),
    );
  }

  double get calculatedTotalQuantity {
    return widget.orderData.orderItems.fold(
      0.0,
      (sum, item) => sum + item.quantity,
    );
  }

  Future<void> _handleSaveOrder() async {
    final username = context.read<AuthProvider>().username;

    final finalOrder = MrnModel(
      orderNumber: "",
      siteName: widget.orderData.siteName,
      executiveName: username,
      orderItems: widget.orderData.orderItems,
      status: 'PENDING',
      totalQty: calculatedTotalQuantity,
      totalAmt: calculatedTotal,
      orderDate: widget.orderData.orderDate,
      tallyStatus: 'Pending',
    );

    setState(() => _isLoading = true);

    try {
      await context.read<MrnProvider>().saveOrder(finalOrder);
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const int minimumRowsCount = 15;
    final int dynamicItemsCount = widget.orderData.orderItems.length;
    final int emptyRowsNeeded = (minimumRowsCount - dynamicItemsCount).clamp(
      0,
      minimumRowsCount,
    );

    final borderColor = Colors.grey.shade400;

    // Direct proportional column widths matching your StockSummary layout
    const Map<int, TableColumnWidth> tableColumnWidths = {
      0: FixedColumnWidth(45.0), // SNo
      1: FixedColumnWidth(250.0), // Product Name
      2: FixedColumnWidth(60.0), // Quantity
      3: FixedColumnWidth(60.0), // UOM
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Review Order',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.4,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isLoading ? null : _handleSaveOrder,
              child: _isLoading
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Save Order',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Info Card Section (Party & Executive Details)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Site: ${widget.orderData.siteName.isEmpty ? "No Name selected" : widget.orderData.siteName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    Row(
                      children: [
                        Text(
                          'Site Engineer: ${context.read<AuthProvider>().username}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 2. Main Data Table Section (Matches Stock Summary Architecture)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Static Header Row
                    Table(
                      border: TableBorder(
                        top: BorderSide(color: borderColor),
                        left: BorderSide(color: borderColor),
                        right: BorderSide(color: borderColor),
                        bottom: BorderSide(color: borderColor),
                        verticalInside: BorderSide(color: borderColor),
                      ),
                      columnWidths: tableColumnWidths,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                          ),
                          children: [
                            _buildTableCell(
                              'S.No',
                              alignment: Alignment.center,
                              isHeader: true,
                            ),
                            _buildTableCell('Product Name', isHeader: true),
                            _buildTableCell(
                              'UOM',
                              alignment: Alignment.center,
                              isHeader: true,
                            ),
                            _buildTableCell(
                              'QTY',
                              alignment: Alignment.center,
                              isHeader: true,
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Vertical-Only Scrollable Dynamic Content Body
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(bottom: 4),
                        itemCount: dynamicItemsCount + emptyRowsNeeded,
                        itemBuilder: (context, index) {
                          final isEven = index % 2 == 0;
                          final isDynamicItem = index < dynamicItemsCount;

                          String sNo = '${index + 1}';
                          String productName = '';
                          String quantity = '';
                          String uom = '';
                          bool isMutedText = !isDynamicItem;

                          if (isDynamicItem) {
                            final item = widget.orderData.orderItems[index];
                            productName = item.stockItemName;
                            quantity = item.quantity.toStringAsFixed(2);
                            uom = item.uom;
                          }

                          return Table(
                            border: TableBorder(
                              left: BorderSide(
                                color: isDynamicItem
                                    ? borderColor
                                    : Colors.grey.shade100,
                              ),
                              right: BorderSide(
                                color: isDynamicItem
                                    ? borderColor
                                    : Colors.grey.shade100,
                              ),
                              bottom: BorderSide(
                                color: isDynamicItem
                                    ? borderColor
                                    : Colors.grey.shade100,
                              ),
                              verticalInside: BorderSide(
                                color: isDynamicItem
                                    ? borderColor
                                    : Colors.grey.shade100,
                              ),
                            ),
                            columnWidths: tableColumnWidths,
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: isEven
                                      ? Colors.white
                                      : const Color(
                                          0xFFFBFCEF,
                                        ).withValues(alpha: 0.2),
                                ),
                                children: [
                                  _buildTableCell(
                                    sNo,
                                    alignment: Alignment.center,
                                    isHeader: false,
                                    isMuted: isMutedText,
                                  ),
                                  _buildTableCell(
                                    productName,
                                    isHeader: false,
                                    maxLines: 1,
                                  ),
                                  _buildTableCell(
                                    uom,
                                    alignment: Alignment.centerRight,
                                    isHeader: false,
                                  ),
                                  _buildTableCell(
                                    quantity,
                                    alignment: Alignment.centerRight,
                                    isHeader: false,
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    // Static Footer Summary Totals Row
                    Table(
                      border: TableBorder(
                        left: BorderSide(color: Colors.grey),
                        top: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey),
                        bottom: BorderSide(color: Colors.grey),
                        verticalInside: BorderSide(color: Colors.grey),
                      ),
                      columnWidths:
                          {0: FlexColumnWidth(3.5), 1: FlexColumnWidth(0.6)}
                              as Map<int, TableColumnWidth>,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                          ),
                          children: [
                            _buildTableCell(
                              'Total Quantity',
                              alignment: Alignment.centerRight,
                              isHeader: true,
                            ),
                            _buildTableCell(
                              calculatedTotalQuantity.toStringAsFixed(2),
                              alignment: Alignment.center,
                              isHeader: false,
                              isTotalRow: true,
                            ),

                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Space at bottom of table
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    Alignment alignment = Alignment.centerLeft,
    required bool isHeader,
    bool isMuted = false,
    bool isTotalRow = false,
    int maxLines = 1,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 12 : 12.5,
          fontWeight: (isHeader || isTotalRow)
              ? FontWeight.w800
              : (isMuted ? FontWeight.bold : FontWeight.w500),
          color: (isHeader || isTotalRow)
              ? const Color(0xFF475569)
              : (isMuted ? Colors.grey.shade500 : const Color(0xFF0F172A)),
          letterSpacing: isHeader ? 0.3 : null,
        ),
      ),
    );
  }
}
