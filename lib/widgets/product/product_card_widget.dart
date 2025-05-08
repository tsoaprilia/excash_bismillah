import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/product/add_edit_product.dart';
import 'package:flutter/material.dart';
import 'package:excash/models/product.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCardWidget extends StatefulWidget {
  final Product product;
  final List<Category> categories;
  final Future<void> Function() refreshProduct;
  final Function(Product, int) updateStock;

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.categories,
    required this.refreshProduct,
    required this.updateStock,
  });

  @override
  _ProductCardWidgetState createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  bool _isStockUpdated = false; // Menyimpan status apakah stok telah diubah
  Color _stockColor = Color(0xFF757B7B); // Default color (warna semula)

  // Variable untuk menyimpan stok sementara yang bisa berubah sesuai klik
  late int _currentStock;
  late int _temporaryStock;

  final _idr = NumberFormat('#,##0', 'id_ID');
  String fRp(int value) => _idr.format(value);

  @override
  void initState() {
    super.initState();
    _currentStock = widget.product.stock; // Menyimpan stok awal produk
    _temporaryStock = _currentStock;
  }

  // Fungsi untuk memperbarui warna stok saat tombol ditekan
  void _changeStockColor() {
    setState(() {
      _isStockUpdated = true;
      _stockColor = Color(0xFFD39054); // Warna yang menandakan perubahan stok
    });
  }

  // Fungsi untuk memperbarui stok berdasarkan penambahan atau pengurangan
  void _updateStock(int change) {
    setState(() {
      if (_temporaryStock + change >= 0) {
        _temporaryStock += change; // Update stok sementara
      }
    });
    _changeStockColor();

    // Update parent widget tentang perubahan stok
    widget.updateStock(
        widget.product, change);
         // Informasikan perubahan stok ke parent widget
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    return userId;
  }

  Future<String> getCategoryName(int idCategory) async {
    final userId = await _getUserId(); // Fetch user_id asynchronously
    final category = widget.categories.firstWhere(
      (cat) => cat.id_category == idCategory,
      orElse: () => Category(
        id_category: 0,
        id: userId ?? 'unknown',
        name_category: "Tidak diketahui",
        created_at_category: DateTime.now(),
        updated_at_category: DateTime.now(),
      ),
    );
    return category.name_category;
  }

  void showNotificationDialog(BuildContext context, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.event_note_outlined,
                        color: const Color(0xFF424242), size: 24),
                    Expanded(
                      child: Text(
                        isSuccess ? 'Notifikasi Berhasil' : 'Notifikasi Gagal',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      isSuccess
                          ? 'assets/img/sukses.png'
                          : 'assets/img/gagal.png',
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSuccess
                                ? 'Berhasil Hapus Data'
                                : 'Gagal Hapus Data',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isSuccess
                                ? 'Selamat, Anda berhasil menghapus data produk!'
                                : 'Maaf, Anda belum berhasil menghapus data produk!',
                            textAlign: TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF757B7B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = _currentStock == 0
    ? Color.fromARGB(15, 226, 54, 63)  // If stock is 0, apply the color #FBEC0
    : Colors.white;  // Default color if stock is not 0
    
    return FutureBuilder<String>(
      future: getCategoryName(widget.product.id_category),
      builder: (context, snapshot) {
        // Check for loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle error if any
        if (snapshot.hasError) {
          return const Center(child: Text("Error fetching category"));
        }

        // If no category name is available in the snapshot
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Kategori tidak ditemukan"));
        }

        final categoryName = snapshot.data ?? "Tidak diketahui";

        // Check if the product is disabled
        return widget.product.is_disabled
            ? Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: cardColor,
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300], // Grey color for disabled product
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.inventory_2_outlined,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.product.name_product,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category_outlined,
                              color: Color(0xFF757B7B), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Kategori: $categoryName",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF757B7B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.sell_outlined,
                              color: Color(0xFFD39054), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Rp. ${fRp(widget.product.selling_price)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFFD39054),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product Disabled Message
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD39054),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.disabled_by_default_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Produk ini dinonaktifkan",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF757B7B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: cardColor,
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.inventory_2_outlined,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.product.name_product,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category_outlined,
                              color: Color(0xFF757B7B), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Kategori: $categoryName",
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF757B7B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.sell_outlined,
                              color: Color(0xFFD39054), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "Rp. ${fRp(widget.product.selling_price)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFFD39054),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button (disabled if product is disabled)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2DECC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFFD39054),
                                    size: 16,
                                  ),
                                  onPressed: widget.product.is_disabled
                                      ? null
                                      : () async {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddEditProductPage(
                                                product: widget.product,
                                                refreshProducts: widget
                                                    .refreshProduct, // Pass refresh callback
                                              ),
                                            ),
                                          ).then((_) {
                                            widget
                                                .refreshProduct(); // Refresh after page close
                                          });
                                        },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Delete Button (disabled if product is disabled)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBCBCBC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFF1E1E1E),
                                    size: 16,
                                  ),
                                  onPressed: widget.product.is_disabled
                                      ? null
                                      : () async {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                backgroundColor: Colors.white,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Header
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .delete_outline,
                                                            color: const Color(
                                                                0xFF424242),
                                                            size: 24,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              "Konfirmasi Hapus",
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xFF424242),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          // Close button with shadow
                                                          Container(
                                                            width: 36,
                                                            height: 36,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.05),
                                                                  blurRadius: 5,
                                                                  spreadRadius:
                                                                      1,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                  Icons.close,
                                                                  size: 18),
                                                              onPressed: () =>
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(
                                                          height: 16),

                                                      // Message
                                                      Text(
                                                        "Apakah Anda yakin ingin menghapus produk ini?",
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF757B7B),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      const SizedBox(
                                                          height: 24),

                                                      // Buttons
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close dialog
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                primary: Colors
                                                                    .white, // Background color of the button
                                                                onPrimary: Color(
                                                                    0xFF424242), // Text color
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            24),
                                                                side: BorderSide(
                                                                    color: Color(
                                                                        0xFF424242)), // Border color
                                                              ),
                                                              child: const Text(
                                                                "Tidak",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  8), // Add space between buttons
                                                          Expanded(
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close dialog
                                                                try {
                                                                  String
                                                                      productId =
                                                                      widget
                                                                          .product
                                                                          .id_product!;
                                                                  int success = await ExcashDatabase
                                                                      .instance
                                                                      .disableProductById(
                                                                          productId);

                                                                  if (success >
                                                                      0) {
                                                                    showNotificationDialog(
                                                                        context,
                                                                        true);
                                                                    widget
                                                                        .refreshProduct();
                                                                  } else {
                                                                    showNotificationDialog(
                                                                        context,
                                                                        false);
                                                                  }
                                                                } catch (e) {
                                                                  print(
                                                                      "Error deleting product: $e");
                                                                  showNotificationDialog(
                                                                      context,
                                                                      false);
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                primary: Colors
                                                                    .white, // Background color of the button
                                                                onPrimary: Color(
                                                                    0xFFD39054), // Text color
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            12,
                                                                        horizontal:
                                                                            24),
                                                                side: BorderSide(
                                                                    color: Color(
                                                                        0xFFD39054)), // Border color
                                                              ),
                                                              child: const Text(
                                                                "Ya",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Decrease Stock Button
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBCBCBC),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.black, size: 16),
                                  onPressed: widget.product.is_disabled
                                      ? null
                                      : () {
                                          _updateStock(
                                              -1); // Decrease stock by 1
                                        },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "$_temporaryStock", // Display current stock
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _stockColor),
                              ),
                              const SizedBox(width: 8),
                              // Increase Stock Button
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.white, size: 16),
                                  onPressed: widget.product.is_disabled
                                      ? null
                                      : () {
                                          _updateStock(
                                              1); // Increase stock by 1
                                        },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
