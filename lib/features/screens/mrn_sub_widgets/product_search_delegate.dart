import 'package:flutter/material.dart';

class ProductSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final List<Map<String, dynamic>> products;
  final Color brandColor;

  ProductSearchDelegate({
    required this.products,
    required this.brandColor,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults();

  Widget _buildSearchResults() {
    final cleanQuery = query.trim().toLowerCase();

    // Global Search Filter across: itemName, itemGroup, and partNumber
    final filteredList = products.where((item) {
      final String name = (item['itemName'] ?? '').toString().toLowerCase();
      final String group = (item['itemGroup'] ?? '').toString().toLowerCase();
      final String partNo = (item['partNumber'] ?? '').toString().toLowerCase();

      return name.contains(cleanQuery) ||
          group.contains(cleanQuery) ||
          partNo.contains(cleanQuery);
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(
        child: Text(
          "No matching materials found.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredList.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final String name = item['itemName']?.toString() ?? 'Unknown';
        final String partNo = item['partNumber']?.toString() ?? 'N/A';
        final String group = item['itemGroup']?.toString() ?? 'General';
        final String uom = item['itemUom']?.toString() ?? '';

        return ListTile(
          onTap: () => close(context, item),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          subtitle: Text(
            "Part No: $partNo  •  UOM: $uom",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: brandColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              group,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: brandColor,
              ),
            ),
          ),
        );
      },
    );
  }
}