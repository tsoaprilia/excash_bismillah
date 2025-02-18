import 'package:flutter/material.dart';
import 'dart:io';
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
    return AspectRatio(
      aspectRatio: 1, // Menyesuaikan ukuran agar tidak overflow
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: Colors.grey[200],
                child: widget.product.image_product == null ||
                        widget.product.image_product!.isEmpty
                    ? const Icon(Icons.image, size: 50, color: Colors.grey)
                    : Image.file(File(widget.product.image_product!),
                        fit: BoxFit.cover),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    widget.product.name_product,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600, // SemiBold
                      color: Color(0xFF424242),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // ID Produk
                  Text(
                    "ID: ${widget.product.id_product}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500, // Medium
                      color: Color(0xFF757B7B),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Harga dan Stok
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp ${widget.product.selling_price}",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD39054), // Warna sesuai permintaan
                        ),
                      ),
                      Text(
                        "Stock: ${widget.product.stock}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Quantity Selector
            const Spacer(),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _decreaseQuantity,
                    icon: const Icon(Icons.remove),
                    color: Colors.black,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Text(
                    quantity.toString(),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _increaseQuantity,
                    icon: const Icon(Icons.add),
                    color: Colors.black,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
