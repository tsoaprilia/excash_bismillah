import 'package:flutter/material.dart';
import 'package:excash/models/product.dart';

class ProductCardBeliWidget extends StatefulWidget {
  final Product product;
  final int initialQuantity;
  final VoidCallback refreshProduct;
  final Function(int) updateTotalAmount;

  const ProductCardBeliWidget({
    super.key,
    required this.product,
    required this.initialQuantity,
    required this.refreshProduct,
    required this.updateTotalAmount,
  });

  @override
  _ProductCardBeliWidgetState createState() => _ProductCardBeliWidgetState();
}

class _ProductCardBeliWidgetState extends State<ProductCardBeliWidget> {
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity; // Ambil jumlah dari cart
  }

  void _increaseQuantity() {
    if (quantity < widget.product.stock || widget.product.stock == 0) {
      // Increase quantity if stock > 0 or product is out of stock but still able to increase
      setState(() {
        quantity++;
        widget.updateTotalAmount(1);
      });
    }
  }

  void _decreaseQuantity() {
    if (quantity > 0) {
      // Decrease quantity only if quantity > 0
      setState(() {
        quantity--;
        widget.updateTotalAmount(-1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isOutOfStock = widget.product.stock == 0;
    bool isMaxStock = quantity >= widget.product.stock;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: isOutOfStock ? Colors.grey[300] : Colors.white, // Ubah warna jika habis stok
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isOutOfStock ? Colors.grey[300] : Colors.white, // Ubah warna jika habis stok
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
                  // Tombol Decrease
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBCBCBC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      onPressed: isOutOfStock ? null : _decreaseQuantity, // Disable jika out of stock
                      icon: const Icon(Icons.remove, size: 16),
                      color: Colors.black,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Menampilkan quantity
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Tombol Increase
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isMaxStock ? Colors.grey : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      onPressed: isMaxStock ? null : _increaseQuantity, // Disable jika stok penuh
                      icon: const Icon(Icons.add, size: 16),
                      color: isMaxStock ? Colors.grey : Colors.white,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
