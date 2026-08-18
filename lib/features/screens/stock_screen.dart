import 'package:flutter/material.dart';
import 'package:mobile_app/features/provider/stock_provider.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockProvider>().fetchAllProductsSummery();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshStocks() async {
    await context.read<StockProvider>().fetchAllProductsSummery();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StockProvider>();
    final stocks = provider.summary;

    final filteredItems = stocks.where((stock) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return stock.itemName.toLowerCase().contains(query);
    }).toList();

    final borderColor = Colors.grey.shade300;

    // Define column widths once for exact structural matching
    const Map<int, TableColumnWidth> tableColumnWidths = {
      0: FixedColumnWidth(45), // S.No
      1: FlexColumnWidth(3),   // Details
      2: FlexColumnWidth(0.7),   // Qty
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Stock Summary',
          style: TextStyle(
            fontWeight: FontWeight.w600,

            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _refreshStocks,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5)),
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  icon: const Icon(Icons.search_rounded, color: Color(0xFF6366F1)),
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                  )
                      : null,
                ),
              ),
            ),
          ),

          // 2. Main Content Data Table Section
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.errorMessage != null
                ? _buildErrorState(provider.errorMessage!)
                : filteredItems.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _refreshStocks,
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
                        bottom: BorderSide(color: borderColor, width: 2),
                        verticalInside: BorderSide(color: borderColor),
                      ),
                      columnWidths: tableColumnWidths,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                          children: [
                            _buildTableCell('S.No', alignment: Alignment.center, isHeader: true),
                            _buildTableCell('Product Details', isHeader: true),
                            _buildTableCell('Quantity', alignment: Alignment.center, isHeader: true),
                          ],
                        ),
                      ],
                    ),

                    // Scrollable Dynamic Content Body
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final stock = filteredItems[index];
                          final isEven = index % 2 == 0;

                          return Table(
                            border: TableBorder(
                              left: BorderSide(color: borderColor),
                              right: BorderSide(color: borderColor),
                              bottom: BorderSide(color: borderColor),
                              verticalInside: BorderSide(color: borderColor),
                            ),
                            columnWidths: tableColumnWidths,
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: isEven ? Colors.white : const Color(0xFFFBFCEF).withValues(alpha: 0.2),
                                ),
                                children: [
                                  _buildTableCell('${index + 1}', alignment: Alignment.center, isHeader: false, isMuted: true),
                                  _buildTableCell(stock.itemName, isHeader: false, maxLines: 2),
                                  _buildTableCell('1.00', alignment: Alignment.centerRight, isHeader: false),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Unified cell builder reduces duplicated methods
  Widget _buildTableCell(
      String text, {
        Alignment alignment = Alignment.centerLeft,
        required bool isHeader,
        bool isMuted = false,
        int maxLines = 1,
      }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isHeader ? 12 : 12.5,
          fontWeight: isHeader
              ? FontWeight.w800
              : (isMuted ? FontWeight.w600 : FontWeight.w600),
          color: isHeader
              ? const Color(0xFF475569)
              : (isMuted ? Colors.grey.shade500 : const Color(0xFF0F172A)),
          letterSpacing: isHeader ? 0.3 : null,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 52, color: Color(0xFF94A3B8)),
              SizedBox(height: 12),
              Text(
                'No products found',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 54, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshStocks,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}