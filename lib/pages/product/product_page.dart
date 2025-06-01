import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/add_edit_product.dart';
import 'package:excash/pages/product/product_cart2_page.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:excash/pages/transaction/print.dart';
import 'package:excash/widgets/product/product_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? _fullName;

  late List<Product> _products;
  late List<Category> _categories;
  var _isLoading = false;

// Menyimpan perubahan stok
  Map<String, int> _productStocks = {};
  bool _hasStockChanges = false;

  String _selectedCategory = "Semua";
  Map<String, int> _categoryMap = {};
  TextEditingController searchController = TextEditingController();
  List<Product> filteredProducts = [];

  Future<void> _getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('user_username') ??
          'Guest'; // Ambil dari key yang benar
    });
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = _getFilteredProducts();
    });
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.BARCODE);

    if (barcodeScanRes != "-1") {
      setState(() {
        searchController.text = barcodeScanRes;
      });
      _filterProducts(barcodeScanRes);
    }
  }

  List<Product> _getFilteredProducts() {
    final query = searchController.text.toLowerCase();
    final selectedCategoryId = _categoryMap[_selectedCategory];

    return _products.where((product) {
      final nameMatch = product.name_product.toLowerCase().contains(query);
      final idMatch = product.id_product.toLowerCase().contains(query);
      final categoryMatch = _selectedCategory == "Semua"
          ? true
          : product.id_category == selectedCategoryId;
      return (nameMatch || idMatch) && categoryMatch && !product.is_disabled;
    }).toList();
  }

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    _products = await ExcashDatabase.instance.getAllProducts();
    _categories = await ExcashDatabase.instance.getAllCategory();

    _categoryMap = {
      for (var category in _categories)
        category.name_category: category.id_category ?? 0,
    };

    final filteredProducts = _getFilteredProducts();
    setState(() => _isLoading = false);
  }

// Fungsi untuk menambah atau mengurangi stok
  void _updateStock(Product product, int change) {
    setState(() {
      int newStock =
          (_productStocks[product.id_product] ?? product.stock) + change;
      newStock = newStock.clamp(0, double.infinity).toInt();

      _productStocks[product.id_product] = newStock;
      product.stock =
          newStock; // <- Tambahkan ini untuk update juga ke daftar _products

      _hasStockChanges = true;
    });
  }

// Fungsi untuk menyimpan perubahan stok
  void _saveUpdatedStocks() async {
    try {
      for (var product in _products) {
        final changedStock = _productStocks[product.id_product];
        if (changedStock != null) {
          await ExcashDatabase.instance.updateProductStock(
            product.id_product,
            changedStock,
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Tunggulah beberapa saat!, Proses penyimpanan"),
      ));

      setState(() {
        _hasStockChanges = false; // Reset perubahan stok setelah disimpan
      });

      // Setelah stok disimpan, kita tidak perlu kembali ke Home, cukup perbarui data.
      _refreshProducts(); // Refresh data setelah stok disimpan
    } catch (e) {
      print("Error updating stock: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshProducts();
    _getFullName();
    _saveUpdatedStocks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();

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
              children: [
                Text(
                  "Selamat Datang",
                  style: TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fullName ?? '',
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
                  Icons.print,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrintSettingsPage()),
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
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(0.1), // Warna shadow lebih soft
                          blurRadius: 8, // Efek shadow lebih lembut
                          spreadRadius: 0, // Tidak menyebar terlalu jauh
                          offset: const Offset(0, 0), // Posisi shadow
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          _filterProducts(value);
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari barang apa?',
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
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    _filterProducts('');
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons
                          .qr_code_scanner, // kamu juga bisa pakai Icons.document_scanner atau lainnya
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: scanBarcode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  // Tombol "Semua" fixed di kiri
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = 'Semua';
                        _filterProducts(searchController.text);
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedCategory == 'Semua'
                            ? Colors.black
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          'Semua',
                          style: TextStyle(
                            color: _selectedCategory == 'Semua'
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ListView.builder untuk kategori lain (exclude 'Semua')
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index].name_category;
                        final isSelected = category == _selectedCategory;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                              _filterProducts(searchController.text);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Center(
                              child: Text(
                                category,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                    // Pass the _refreshProducts callback to AddEditProductPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditProductPage(
                          refreshProducts:
                              _refreshProducts, // Pass the callback here
                        ),
                      ),
                    ).then((_) {
                      _refreshProducts(); // Panggil _refreshProducts setelah halaman AddEditProductPage ditutup
                    });
// Refresh products after returning from Add/Edit page
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
                      ? RefreshIndicator(
                          onRefresh: _refreshProducts,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 200),
                              Center(child: Text('Produk Kosong')),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refreshProducts,
                          child: ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCardWidget(
                                product: product,
                                categories: _categories,
                                refreshProduct: _refreshProducts,
                                updateStock: _updateStock,
                              );
                            },
                          ),
                        ),
            )
          ],
        ),
      ),
      floatingActionButton:
          _hasStockChanges // Tampilkan FloatingButton jika ada perubahan stok
              ? FloatingActionButton.extended(
                  onPressed: _saveUpdatedStocks,
                  label: const Text(
                    "Simpan Stok Baru",
                    style: TextStyle(
                        color: Colors
                            .white), // Menetapkan warna teks menjadi putih
                  ),
                  icon: const Icon(
                    Icons.save,
                    color: Colors.white, // Menetapkan warna ikon menjadi putih
                  ),
                  backgroundColor: const Color(0xFFD39054),
                  foregroundColor: Colors
                      .white, // Menetapkan warna ikon dan teks menjadi putih
                )
              : null, // Jika tidak ada perubahan stok, tombol hilang
      // Jika tidak ada perubahan stok, tombol hilang
    );
  }
}
