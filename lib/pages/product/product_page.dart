import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/add_edit_product.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:excash/widgets/product/product_card_widget.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late List<Product> _products;
   late List<Category> _categories;
  var _isLoading = false;

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    _products = await ExcashDatabase.instance.getAllProducts();
    _categories = await ExcashDatabase.instance.getAllCategory();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  'assets/img/excash_logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Column(
              children: const [
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Aprilia Dwi Cristyana",
                  style: TextStyle(
                    color: Color(0xFF424242),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductCartPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Produk',
                  hintStyle: const TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1E1E1E),
                    size: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.format_list_bulleted_outlined,
                      color: Color(0xFF1E1E1E),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Produk Saya',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (context) => const AddEditProductPage(),
                    );
                    _refreshProducts();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    '+ Tambah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _products.isEmpty
                      ? const Center(child: Text('Produk Kosong'))
                      : ListView.builder(
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCardWidget(
                              product: product,
                              categories: _categories, 
                              refreshProduct: _refreshProducts,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
