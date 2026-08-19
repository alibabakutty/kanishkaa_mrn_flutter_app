import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/model/order_item_model.dart';
import 'package:mobile_app/features/screens/checkout_screen.dart';
import 'package:mobile_app/features/service/api_service.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/features/provider/auth_provider.dart';

class MaterialReceiptNoteScreen extends StatefulWidget {
  const MaterialReceiptNoteScreen({super.key});

  @override
  State<MaterialReceiptNoteScreen> createState() =>
      _MaterialReceiptNoteScreenState();
}

class _MaterialReceiptNoteScreenState extends State<MaterialReceiptNoteScreen> {
  final Color brandColor = const Color(0xFF0C685B);
  final ApiService _apiService = ApiService();

  // Active state variables
  String _selectedSite = "Select Location";
  bool _isLoadingSites = false;
  bool _isLoadingProducts = false;

  // Dynamic API Lists
  List<Map<String, dynamic>> _siteDatabase = [];
  List<Map<String, dynamic>> _productDatabase = [];

  final List<Map<String, dynamic>> _addedItems = [];

  // Helper getters for cart state
  bool get _hasItems => _addedItems.isNotEmpty;
  int get _totalUniqueItems => _addedItems.length;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _fetchSites();
    _fetchInventory();
  }

  // 1. Fetch Sites via Dio
  Future<void> _fetchSites() async {
    setState(() => _isLoadingSites = true);
    try {
      final sites = await _apiService.fetchSites();
      setState(() {
        _siteDatabase = sites;
      });
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoadingSites = false);
    }
  }

  // 2. Fetch Inventory via Dio
  Future<void> _fetchInventory() async {
    setState(() => _isLoadingProducts = true);
    try {
      final items = await _apiService.fetchInventory();
      setState(() {
        _productDatabase = items;
      });
    } catch (e) {
      _showSnackBar(e.toString().replaceAll("Exception: ", ""));
    } finally {
      setState(() => _isLoadingProducts = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Show discard warning if user has items added
  Future<bool> _showDiscardDialog() async {
    if (!_hasItems) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
            'You have added materials to this MRN. Are you sure you want to exit and clear your selection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _resetOrder() {
    setState(() {
      _addedItems.clear();
      _selectedSite = "Select Location";
    });
  }

  void _pickSiteViaDelegate() async {
    if (_isLoadingSites) {
      _showSnackBar("Sites are still loading...");
      return;
    }

    final Map<String, dynamic>? result =
        await showSearch<Map<String, dynamic>?>(
      context: context,
      delegate: UniversalStringSearchDelegate(
        title: "Search Construction Sites",
        dataset: _siteDatabase,
        brandColor: brandColor,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSite = result['siteName'] ?? "Unknown Site";
      });
    }
  }

  void _pickProductViaDelegate() async {
    if (_isLoadingProducts) {
      _showSnackBar("Inventory items are still loading...");
      return;
    }

    final Map<String, dynamic>? result =
        await showSearch<Map<String, dynamic>?>(
      context: context,
      delegate: ProductSearchDelegate(
        products: _productDatabase,
        brandColor: brandColor,
      ),
    );

    if (result != null) {
      int existingIndex = _addedItems.indexWhere(
        (item) => item['id'] == result['id'],
      );
      setState(() {
        if (existingIndex >= 0) {
          _addedItems[existingIndex]['qty'] += 1;
        } else {
          _addedItems.add({
            "id": result['id'],
            "name": result['itemName'],
            "partNumber": result['partNumber']?.toString() ?? '',
            "itemUom": result['itemUom'] ?? '',
            "qty": 1,
            "rate": (result['itemRate'] as num?)?.toDouble() ?? 0.0,
          });
        }
      });
    }
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      _addedItems[index]['qty'] += delta;
      if (_addedItems[index]['qty'] <= 0) {
        _addedItems.removeAt(index);
      }
    });
  }

  // Add this getter in _MaterialReceiptNoteScreenState class
  MrnModel get currentOrderData {
    // Convert the added items to OrderItemModel list
    final orderItems = _addedItems.map((item) {
      return OrderItemModel(
        partNumber: item['partNumber']?.toString() ?? '',
        stockItemName: item['name'] ?? '',
        uom: item['itemUom'] ?? '',
        quantity: (item['qty'] as num).toDouble(),
        rate: (item['rate'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

  return MrnModel(
    orderNumber: "", // Will be generated by backend
    siteName: _selectedSite == "Select Location" ? "" : _selectedSite,
    executiveName: context.read<AuthProvider>().username ?? '',
    orderItems: orderItems,
    status: 'PENDING',
    totalQty: 0.0,
    totalAmt: 0.0, // This will be recalculated in CheckoutScreen
    orderDate: DateTime.now(),
    tallyStatus: 'Pending',
  );
}

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username ?? "Admin";

    return PopScope(
      canPop: !_hasItems,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final bool shouldLeave = await _showDiscardDialog();
        if (shouldLeave && context.mounted) {
          _resetOrder();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F9),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () async {
              final bool shouldLeave = await _showDiscardDialog();
              if (shouldLeave && context.mounted) {
                _resetOrder();
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text(
            "New MRN",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
          // Current Date
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.7),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat('dd MMM yyyy').format(DateTime.now()),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Review Button
          if (_hasItems)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _selectedSite == "Select Location"
                    ? () => _showSnackBar(
                        "Please select a site location first.",
                      )
                    : () async {
                        final bool? orderSavedSuccessfully =
                            await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (context) => CheckoutScreen(
                              orderData: currentOrderData,
                            ),
                          ),
                        );

                        if (orderSavedSuccessfully == true) {
                          setState(() {
                            _resetOrder();
                          });
                        }
                      },
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 16,
                ),
                label: Text(
                  'Review ($_totalUniqueItems)',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _loadInitialData,
          ),
        ],
        ),
        body: Column(
          children: [
            // Header Block
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person_pin, color: brandColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            username,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.grey.shade300),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: _pickSiteViaDelegate,
                      borderRadius: BorderRadius.circular(4),
                      child: Row(
                        children: [
                          Icon(Icons.location_city,
                              color: brandColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _isLoadingSites
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : Text(
                                    _selectedSite,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: _selectedSite == "Select Location"
                                          ? Colors.orange.shade800
                                          : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: InkWell(
                onTap: _pickProductViaDelegate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: brandColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isLoadingProducts
                              ? "Loading materials..."
                              : "Search product items to add...",
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Added Items List
            Expanded(
              child: _addedItems.isEmpty
                  ? Center(
                      child: Text(
                        "No products listed yet.",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _addedItems.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemBuilder: (context, index) {
                        final item = _addedItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Part No: ${item['partNumber']?.toString() ?? ''} | UOM: ${item['itemUom']?.toString() ?? ''}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () => _updateQuantity(index, -1),
                                    child: Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.grey.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                    child: Text(
                                      "${item['qty']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () => _updateQuantity(index, 1),
                                    child: Icon(
                                      Icons.add_circle_outline,
                                      color: brandColor,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Search Delegates stay the same
class UniversalStringSearchDelegate
    extends SearchDelegate<Map<String, dynamic>?> {
  final String title;
  final List<Map<String, dynamic>> dataset;
  final Color brandColor;

  UniversalStringSearchDelegate({
    required this.title,
    required this.dataset,
    required this.brandColor,
  });

  @override
  String get searchFieldLabel => title;

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _filterData();

  @override
  Widget buildSuggestions(BuildContext context) => _filterData();

  Widget _filterData() {
    final filtered = dataset
        .where((item) => (item['siteName'] ?? '')
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No matching site records found."),
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final site = filtered[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 0.7,
              ),
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 0.7,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          child: InkWell(
            onTap: () => close(context, site),
            child: Row(
              children: [
                // Site icon
                Icon(
                  Icons.location_on_outlined,
                  color: brandColor,
                  size: 20,
                ),

                const SizedBox(width: 10),

                // Site details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        site['siteName'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        "Status: ${site['siteStatus'] ?? 'N/A'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Select indicator
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> products;
  final Color brandColor;

  ProductSearchDelegate({required this.products, required this.brandColor});

  @override
  String get searchFieldLabel => "Search Inventory Materials";

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear), onPressed: () => query = ''),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _renderItems();

  @override
  Widget buildSuggestions(BuildContext context) => _renderItems();

  Widget _renderItems() {
    final suggestions = products
        .where((p) =>
            (p['itemName'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (p['partNumber'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    if (suggestions.isEmpty) {
      return const Center(child: Text("No inventory materials match."));
    }

    return ListView.builder(
      itemCount: suggestions.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final item = suggestions[index];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade300,
                width: 0.7,
              ),
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 0.7,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          child: Row(
            children: [
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['itemName'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      "Part No: ${item['partNumber'] ?? ''} | "
                      "UOM: ${item['itemUom'] ?? ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Add button
              SizedBox(
                height: 28,
                child: ElevatedButton.icon(
                  onPressed: () => close(context, item),
                  icon: const Icon(
                    Icons.add,
                    size: 14,
                  ),
                  label: const Text(
                    "Add",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}