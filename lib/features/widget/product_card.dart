import 'package:flutter/material.dart';
import 'package:mobile_app/features/model/product_model.dart';
import 'quantity_button.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final num quantity;
  final Color borderColor;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<num> onQuantityChanged;


  const ProductCard({
    super.key,
    required this.product,
    required this.quantity,
    required this.borderColor,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    // final hasImage = product.imageBytes != null && product.imageBytes!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // child: ClipRRect(
                    //   borderRadius: BorderRadius.circular(8),
                    //   child: hasImage
                    //       ? Image.memory(
                    //     product.imageBytes!,
                    //     fit: BoxFit.contain,
                    //     // cacheWidth: 150,
                    //     // cacheHeight: 250,
                    //     filterQuality: FilterQuality.low,
                    //     errorBuilder: (context, error, stackTrace) {
                    //       return Container(
                    //         color: Colors.grey.shade200,
                    //         child: const Center(
                    //           child: Icon(
                    //             Icons.broken_image_outlined,
                    //             size: 32,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   )
                    //       : Container(
                    //     color: Colors.grey.shade200,
                    //     child: const Center(
                    //       child: Icon(
                    //         Icons.image_not_supported,
                    //         size: 32,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: QuantityButton(
                      quantity: quantity,
                      onAdd: onAdd,
                      onIncrement: onIncrement,
                      onDecrement: onDecrement,
                      onQuantityChanged: onQuantityChanged,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              product.uom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.pink,
                  letterSpacing: 5

              ),
            ),
              SizedBox(height: 10,),
              Expanded(
                flex: 2,
                child: Text(
                  '${product.itemCode} - ${product.itemName}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Colors.black87,

                  ),
                ),
              ),


          ],
        ),
      ),
    );
  }
}