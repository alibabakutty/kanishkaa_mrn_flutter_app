import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/product_summary_model.dart';

class ProductSearchDelegate extends SearchDelegate<ProductSummaryModel?> {
  final List<ProductSummaryModel> allProducts;

  ProductSearchDelegate({required this.allProducts});

  // Clear query button (Right side of App Bar)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  // Back button to dismiss search (Left side of App Bar)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  // Action taken when pressing search on keyboard
  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  // Real-time search suggestions while typing
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  // Helper widget to construct product list with '+' add buttons
  Widget _buildSearchResults(BuildContext context) {
    final filteredList = allProducts.where((product) {
      return product.itemName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (filteredList.isEmpty) {
      return Center(
        child: Text(
          query.isEmpty
              ? "Type product name to search..."
              : "No products found",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: filteredList.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = filteredList[index];

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 4.0,
          ),
          title: Text(
            product.itemName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            "UOM: ${product.uom}",
            style: TextStyle(color: Colors.pink, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          // Right + Icon for adding product directly
          trailing: IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFF4F46E5),
              size: 28,
            ),
            onPressed: () {
              // Closes search and returns the selected item to main screen
              close(context, product);
            },
          ),
          onTap: () {
            close(context, product);
          },
        );
      },
    );
  }
}
