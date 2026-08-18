import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/mrn_model.dart';
import 'package:mobile_app/features/model/product_model.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<ProductModel> onAdd;
  final ValueChanged<ProductModel> onIncrement;
  final ValueChanged<ProductModel> onDecrement;
  final Color borderColor;
  final MrnModel orderModel;
  final ScrollController controller;
  final double bottomPadding;
  final Function(ProductModel product, num qty) onQuantityChanged;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    required this.borderColor,
    required this.orderModel,
    required this.controller,
    required this.bottomPadding,
    required this.onQuantityChanged,
  });

  num getProductQuantity(ProductModel product) {
    final index = orderModel.orderItems.indexWhere(
          (item) => item.stockItemName == product.itemName,
    );

    if (index == -1) return 0;
    return orderModel.orderItems[index].quantity;
  }

  @override
  Widget build(BuildContext context) {
    const double crossAxisSpacing = 8;
    const double mainAxisSpacing = 8;
    const double paddingAmount = 8;

    final double safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final double gridBottomPadding = safeBottom > 0 ? safeBottom + 4 : 8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double usableHeight = constraints.maxHeight
            - paddingAmount
            - gridBottomPadding
            - mainAxisSpacing;

        final double itemHeight = (usableHeight / 2).floorToDouble();

        return GridView.builder(
          controller: controller,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            paddingAmount,
            paddingAmount,
            paddingAmount,
            gridBottomPadding,
          ),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            final quantity = getProductQuantity(product);

            return ProductCard(
              key: ValueKey(product.itemName),
              product: product,
              quantity: quantity,
              borderColor: borderColor,
              onAdd: () => onAdd(product),
              onIncrement: () => onIncrement(product),
              onDecrement: () => onDecrement(product),
              onQuantityChanged: (qty){
                onQuantityChanged(product, qty);
              },
            );
          },
        );
      },
    );
  }
}