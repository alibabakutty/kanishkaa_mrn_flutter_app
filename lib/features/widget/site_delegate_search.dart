import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/site_model.dart';

class SiteDelegateSearch extends SearchDelegate<SiteModel> {
  final List<SiteModel> sites;

  SiteDelegateSearch({required this.sites});

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

  // Back button on the left (close search view)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // to safely handle cancelling out
        Navigator.of(context).pop(null);
      },
    );
  }

  // results showin when user press search button
  @override
  Widget buildResults(BuildContext context) {
    return _buildSiteList(context);
  }

  // suggestions list shown as the user types in the search field
  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSiteList(context);
  }

  Widget _buildSiteList(BuildContext context) {
    final filteredList = query.isEmpty
      ? sites 
      : sites.where((site) {
        return site.siteName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      if(filteredList.isEmpty) {
        return const Center(
          child: Text('No sites found.'),
        );
      }

      return NotificationListener<ScrollNotification> (
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            // Handle scroll updates
            FocusManager.instance.primaryFocus?.unfocus();
          }
          return false;
        },
        child: ListView.builder(
          itemCount: filteredList.length,
          itemBuilder: (context, index){
            final site = filteredList[index];
            return ListTile(
              title: Text(site.siteName),
              subtitle: Text('Status: ${site.siteStatus}'),
              leading: const Icon(Icons.location_city),
              onTap: () {
                close(context, site); // successfully return the selected site
              },
            );
          },
        )
      );
  }
}