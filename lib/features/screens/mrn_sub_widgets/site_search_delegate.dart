import 'package:flutter/material.dart';

class SiteSearchDelegate extends SearchDelegate<Map<String, dynamic>?> {
  final String title;
  final List<Map<String, dynamic>> dataset;
  final Color brandColor;

  SiteSearchDelegate({
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
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
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
                Icon(
                  Icons.location_on_outlined,
                  color: brandColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
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