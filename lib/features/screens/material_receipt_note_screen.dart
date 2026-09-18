import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/model/order_item_model.dart';
import 'package:mobile_app/features/screens/checkout_screen.dart';
import 'package:mobile_app/features/screens/mrn_sub_widgets/quantity_selector.dart';
import 'package:mobile_app/features/service/api_service.dart';
import 'package:mobile_app/features/screens/mrn_sub_widgets/product_search_delegate.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/features/provider/auth_provider.dart';
import 'package:mobile_app/features/screens/mrn_sub_widgets/site_search_delegate.dart';

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
  MrnOrderCompany _selectedCompany =
      MrnOrderCompany.KANISHKAA_CIVIL_ENGINEERING_PRIVATE_LIMITED;
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
      _selectedCompany =
          MrnOrderCompany.KANISHKAA_CIVIL_ENGINEERING_PRIVATE_LIMITED;
    });
  }

  /// Returns the exact siteCompany string matching the API JSON payload
  String _getCompanyFullString(MrnOrderCompany company) {
    switch (company) {
      case MrnOrderCompany.KANISHKAA_CIVIL_ENGINEERING_PRIVATE_LIMITED:
        return "KANISHKAA CIVIL ENGINEERING PRIVATE LIMITED";
      case MrnOrderCompany.KANISHKAA_FOUNDATION:
        return "KANISHKAA FOUNDATION";
      case MrnOrderCompany.SHREE_VRIKSHAH_HOMES:
        return "SHREE VRIKSHAH HOMES";
      case MrnOrderCompany.SHREE_VRIKSHAH_HOMES_LLP:
        return "SHREE VRIKSHAH HOMES LLP";
    }
  }

  String _getCompanyDisplayName(MrnOrderCompany company) {
    switch (company) {
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

  void _pickSiteViaDelegate() async {
    if (_isLoadingSites) {
      _showSnackBar("Sites are still loading...");
      return;
    }

    // Filter site database by currently selected company
    final String targetCompany = _getCompanyFullString(_selectedCompany);
    final List<Map<String, dynamic>> filteredSites = _siteDatabase
        .where((site) =>
            site['siteCompany']?.toString().trim() == targetCompany.trim())
        .toList();

    if (filteredSites.isEmpty) {
      _showSnackBar(
          "No sites available for ${_getCompanyDisplayName(_selectedCompany)}");
      return;
    }

    final Map<String, dynamic>? result =
        await showSearch<Map<String, dynamic>?>(
      context: context,
      delegate: SiteSearchDelegate(
        title: "Search Construction Sites",
        dataset: filteredSites,
        brandColor: brandColor,
      ),
    );

    if (result != null) {
      setState(() {
        // Trim newlines (\n) present in API siteName
        _selectedSite =
            (result['siteName']?.toString() ?? "Unknown Site").trim();
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
            "partNumber": result['partNumber']?.toString() ?? 'N/A',
            "itemGroup": result['itemGroup']?.toString() ?? 'General',
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

  MrnModel get currentOrderData {
    final orderItems = _addedItems.map((item) {
      return OrderItemModel(
        partNumber: item['partNumber']?.toString() ?? '',
        stockItemName: item['name'] ?? '',
        stockItemGroup: item['itemGroup']?.toString() ?? 'General',
        uom: item['itemUom'] ?? '',
        quantity: (item['qty'] as num).toDouble(),
        rate: (item['rate'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    return MrnModel(
      orderNumber: "",
      siteName: _selectedSite == "Select Location" ? "" : _selectedSite,
      executiveId: context.read<AuthProvider>().userEmployeeId,
      executiveName: context.read<AuthProvider>().username,
      company: context.read<AuthProvider>().company,
      mrnOrderCompany: _selectedCompany,
      orderItems: orderItems,
      status: 'PENDING',
      totalQty: 0.0,
      totalAmt: 0.0,
      orderDate: DateTime.now(),
      tallyStatus: 'PENDING',
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username;

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
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  username,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  "New MRN",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateFormat('dd MMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (_hasItems)
              Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _selectedSite == "Select Location"
                      ? () => _showSnackBar("Please select a location first.")
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
                  icon: const Icon(Icons.shopping_cart_outlined, size: 14),
                  label: Text(
                    'Review ($_totalUniqueItems)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              onPressed: _loadInitialData,
            ),
          ],
        ),
        body: Column(
          children: [
            // Company & Location Selector Row
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Company Selector
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.business, color: brandColor, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<MrnOrderCompany>(
                                value: _selectedCompany,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: brandColor,
                                  size: 18,
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                onChanged: (MrnOrderCompany? newValue) {
                                  if (newValue != null &&
                                      newValue != _selectedCompany) {
                                    setState(() {
                                      _selectedCompany = newValue;
                                      // Reset selected site when company changes to prevent mismatched location selection
                                      _selectedSite = "Select Location";
                                    });
                                  }
                                },
                                items: MrnOrderCompany.values.map((company) {
                                  return DropdownMenuItem<MrnOrderCompany>(
                                    value: company,
                                    child: Text(
                                      _getCompanyDisplayName(company),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Filtered Location Picker
                  Expanded(
                    flex: 5,
                    child: InkWell(
                      onTap: _pickSiteViaDelegate,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_city,
                              color: brandColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _isLoadingSites
                                  ? const SizedBox(
                                      height: 12,
                                      width: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _selectedSite,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemBuilder: (context, index) {
                        final item = _addedItems[index];
                        final String group = item['itemGroup']?.toString() ?? '';
                        final String partNo = item['partNumber']?.toString() ?? 'N/A';
                        final String uom = item['itemUom']?.toString() ?? '';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left Content: Item details compactly aligned
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Top Row: Item Name + Group Tag
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.5,
                                              height: 1.1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (group.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: brandColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              group,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: brandColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Bottom Row: Part No & UOM
                                    Text(
                                      "Part: $partNo  •  UOM: $uom",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10.5,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Right Content: Quantity Selector
                              QuantitySelector(
                                quantity: item['qty'],
                                brandColor: brandColor,
                                onChanged: (newQty) {
                                  setState(() {
                                    _addedItems[index]['qty'] = newQty;
                                  });
                                },
                                onIncrement: () => _updateQuantity(index, 1),
                                onDecrement: () => _updateQuantity(index, -1),
                              ),
                            ],
                          ),
                        );
                      },
                    )
            ),
          ],
        ),
      ),
    );
  }
}