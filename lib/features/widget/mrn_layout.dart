import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/model/product_model.dart';
import 'product_grid.dart';
import 'search_app_bar.dart';

class MrnLayout extends StatelessWidget {
  final Color cellBorderColor;
  final int selectedCategoryIndex;
  final ValueChanged<int> onCategorySelected;
  final ValueChanged<String> onSearchChanged;
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onAdd;
  final ValueChanged<ProductModel> onIncrement;
  final ValueChanged<ProductModel> onDecrement;
  final Function(ProductModel product, num qty) onQuantityChanged;
  final MrnModel orderModel;
  final ScrollController controller;
  final double bottomPadding;

  const MrnLayout({
    super.key,
    required this.cellBorderColor,
    required this.selectedCategoryIndex,
    required this.onCategorySelected,
    required this.onSearchChanged,
    required this.products,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    required this.orderModel,
    required this.controller,
    required this.bottomPadding,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Column(
      children: [
        SearchAppBar(
          cellBorderColor: cellBorderColor,
          onChanged: onSearchChanged,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: keyBoardHeight),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ProductGrid(
                      controller: controller,
                      products: products,
                      orderModel: orderModel,
                      borderColor: cellBorderColor,
                      onAdd: onAdd,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                      bottomPadding: bottomPadding,
                      onQuantityChanged: onQuantityChanged
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
