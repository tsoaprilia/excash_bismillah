import 'package:excash/models/order.dart';
import 'package:excash/models/user.dart';
import 'package:excash/services/shared_pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/product_cart2_page.dart';
import 'package:excash/widgets/product/product_card_beli_widget.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, int> _categoryMap = {};

  String _userName = "Nama Pengguna";
  String _userEmail = "Email Pengguna";
  String _userbusinessName = "Nama Bisnis";

  TextEditingController searchController = TextEditingController();
  List<Product> filteredProducts = [];

  List<Product> _products = [];
  List<String> _categories = ["Semua"];
  String _selectedCategory = "Semua";
  bool _isLoading = false;
  int totalAmount = 0;

  // Data keranjang belanja
  List<Map<String, dynamic>> cart = [];

  @override
  void initState() {
    super.initState();
    _refreshProducts();

    _loadUserData();

    // Tambahkan focus listener untuk menyegarkan data ketika halaman mendapat fokus kembali
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusNode = FocusNode();
      FocusScope.of(context).requestFocus(focusNode);
      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          _refreshProducts();
        }
      });
    });
  }

  void _clearCart() {
    setState(() {
      cart.clear(); // Mengosongkan keranjang belanja
      totalAmount = 0; // Reset total amount
    });
    // Memanggil fungsi untuk memperbarui produk
    _refreshProducts();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_username') ?? "Nama Pengguna";
      _userEmail = prefs.getString('user_email') ?? "Email Pengguna";
      _userbusinessName =
          prefs.getString('user_business_name') ?? "Nama Bisnis";
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() => _isLoading = true);
    try {
      final categoriesData = await ExcashDatabase.instance.getAllCategory();
      final categories = <String>{"Semua"};
      _categoryMap.clear();

      for (var category in categoriesData) {
        categories.add(category.name_category);
        _categoryMap[category.name_category] = category.id_category!;
      }

      final products = await ExcashDatabase.instance.getAllProducts();

      final activeProducts =
          products.where((product) => !product.is_disabled).toList();

      setState(() {
        _products = activeProducts;
        filteredProducts = activeProducts;
        _categories = categories.toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Cancel",
        true,
        ScanMode.BARCODE,
      );

      if (barcodeScanRes != "-1") {
        setState(() {
          searchController.text =
              barcodeScanRes; // <-- Set hasil scan ke search field
          _filterProducts(barcodeScanRes); // <-- Filter berdasarkan hasil scan
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Product ID: $barcodeScanRes scanned successfully!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Barcode scan was cancelled")));
      }
    } catch (e) {
      print("Error scanning barcode: $e");
    }
  }

// Modify _filterProducts to ensure proper filtering based on Product ID (from barcode scan)
  void _filterProducts(String query) {
    setState(() {
      filteredProducts = _products.where((product) {
        // Match barcode scan result with product ID
        final idMatch =
            product.id_product.toLowerCase().contains(query.toLowerCase());
        final nameMatch =
            product.name_product.toLowerCase().contains(query.toLowerCase());
        final categoryMatch = _selectedCategory == "Semua"
            ? true
            : product.id_category == _categoryMap[_selectedCategory];

        return (nameMatch || idMatch) &&
            categoryMatch &&
            !product.is_disabled; // Exclude disabled products
      }).toList();

      // Log the filtered products for verification
      filteredProducts.forEach((product) {
        print(
            "Filtered Product: ${product.name_product}, ${product.id_product}");
      });
    });
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
      return (nameMatch || idMatch) &&
          categoryMatch &&
          !product.is_disabled; // Exclude disabled products
    }).toList();
  }

  void _updateTotalAmount(Product product, int change) {
    setState(() {
      totalAmount += change;
    });

    // Update jumlah produk di keranjang
    final index = cart
        .indexWhere((item) => item['product'].id_product == product.id_product);
    if (index != -1) {
      cart[index]['quantity'] += change;
      if (cart[index]['quantity'] <= 0) {
        cart.removeAt(index);
      }
    } else if (change > 0) {
      cart.add({'product': product, 'quantity': change});
    }
  }

  int getTotalItems() {
    return cart.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
  }

  double getTotalPrice() {
    return cart.fold(
        0,
        (sum, item) =>
            sum +
            (item['product'].selling_price *
                item['quantity'])); // 🟢 Ditambahkan: Hitung total harga
  }

  int getProductQuantity(Product product) {
    final index = cart
        .indexWhere((item) => item['product'].id_product == product.id_product);
    return index != -1
        ? cart[index]['quantity']
        : 0; // 🟢 Ditambahkan: Ambil jumlah item dari cart
  }

  Future<void> saveCurrentUser(
      String userId, String fullName, String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('fullName', fullName);
    await prefs.setString('user_email', userEmail);
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
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _userName,
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
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductCart2Page(
                        cart: cart,
                        onTransactionSuccess: () {
                          // Clear the cart after a successful transaction
                          setState(() {
                            cart.clear(); // Reset cart
                            totalAmount = 0; // Reset total amount
                          });
                          _refreshProducts();
                        },
                      ),
                    ),
                  ).then((_) => _refreshProducts());
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
            const SizedBox(height: 10),

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
                        _filterProducts(searchController
                            .text); // 🟢 Tambahkan ini agar filter diperbarui
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
                      : RefreshIndicator(
                          onRefresh:
                              _refreshProducts, // Tambahkan fungsi refresh
                          child: ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ProductCardBeliWidget(
                                product: product,
                                initialQuantity: getProductQuantity(product),
                                refreshProduct: _refreshProducts,
                                updateTotalAmount: (change) =>
                                    _updateTotalAmount(product, change),
                              );
                            },
                          ),
                        ),
            )
          ],
        ),
      ),
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCart2Page(
                      cart: cart,
                      onTransactionSuccess: () {
                        // Clear the cart after a successful transaction
                        setState(() {
                          cart.clear(); // Reset cart
                          totalAmount = 0; // Reset total amount
                        });
                        _refreshProducts();
                      },
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFFD39054), // Warna latar belakang
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20), // Membuat sudut membulat
              ),
              label: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shopping_cart,
                          color: Colors.white, size: 20), // Ikon keranjang
                      const SizedBox(width: 8),
                      Text(
                        "${getTotalItems()}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(
                      width: 20), // Jarak antara total item dan harga
                  Text(
                    "Rp ${getTotalPrice().toInt()}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
