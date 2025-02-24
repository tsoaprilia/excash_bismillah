import 'package:flutter/material.dart';
import 'package:excash/models/product.dart';

class ProductCardBeliWidget extends StatefulWidget {
  final Product product;
  final VoidCallback refreshProduct;

  const ProductCardBeliWidget({
    super.key,
    required this.product,
    required this.refreshProduct,
  });

  @override
  _ProductCardBeliWidgetState createState() => _ProductCardBeliWidgetState();
}

class _ProductCardBeliWidgetState extends State<ProductCardBeliWidget> {
  int quantity = 0;

  void _increaseQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decreaseQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian kiri: ID dan Nama Produk
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ID: ${widget.product.id_product}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500, // Medium
                      color: Color(0xFF757B7B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(widget.product.name_product,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600, // SemiBold
                        color: Color(0xFF424242),
                      ),
                      maxLines: 2),
                ],
              ),
              // Bagian kanan: Quantity Selector
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBCBCBC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      onPressed: _decreaseQuantity,
                      icon: const Icon(Icons.remove, size: 16),
                      color: Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      onPressed: _increaseQuantity,
                      icon: const Icon(Icons.add, size: 16),
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(), // Hilangkan margin bawaan IconButton
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}