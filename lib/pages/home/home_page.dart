import 'package:excash/database/excash_database.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:excash/widgets/product/product_card_beli_widget.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  List<String> _categories = ["Semua"];
  String _selectedCategory = "Semua";
  bool _isLoading = false;

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    final products = await ExcashDatabase.instance.getAllProducts();

    setState(() {
      _products = products;
      _categories = ["Semua", ..._products.map((p) => p.category).toSet()];
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = "Semua";
      }
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts();

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
            // Search Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
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

            // Kategori Produk
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Daftar Produk
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredProducts.isEmpty
                      ? const Center(child: Text('Produk Kosong'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(0),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 6,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCardBeliWidget(
                              product: product,
                              refreshProduct: () {
                                _refreshProducts();
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Filter produk berdasarkan kategori
  List<Product> _filteredProducts() {
    if (_products.isEmpty) return [];
    if (_selectedCategory == "Semua") {
      return _products;
    } else {
      return _products
          .where((product) => product.category == _selectedCategory)
          .toList();
    }
  }
}
