import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/site_model.dart';
import 'package:mobile_app/features/widget/site_delegate_search.dart';

class SiteSection extends StatelessWidget {
  final List<SiteModel> sites;
  final TextEditingController controller;
  final ValueChanged<SiteModel> onSiteSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback resetOrder;

  const SiteSection({
    super.key,
    required this.sites,
    required this.controller,
    required this.onSiteSelected,
    required this.onSearchChanged,
    required this.resetOrder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return TextField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            //opens full-screen search delegate
            final SiteModel? selectedSite = await showSearch<SiteModel>(
              context: context,
              delegate: SiteDelegateSearch(sites: sites),
            );

            // if the user picked a site, update the text field and notify the parent widget
            if (selectedSite != null) {
              controller.text = selectedSite.siteName;
              onSiteSelected(selectedSite);
              onSearchChanged(selectedSite.siteName);
            }
          },
          decoration: InputDecoration(
            labelText: 'Site Name',
            hintText: 'Tab to select a site',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onSearchChanged('');
                    resetOrder();
                  }
                ) : const Icon(Icons.arrow_forward_ios, size: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
          ),
        );
      }
    );
  }
}