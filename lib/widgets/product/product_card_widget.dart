import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/product/add_edit_product.dart';
import 'package:flutter/material.dart';
import 'package:excash/models/product.dart';

class ProductCardWidget extends StatelessWidget {
  final Product product;
  final List<Category> categories;
  final VoidCallback refreshProduct;
  // Tambahkan daftar kategori

  const ProductCardWidget({
    super.key,
    required this.product,
    required this.categories,
    required this.refreshProduct,
  });

  void showNotificationDialog(BuildContext context, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white, // Pastikan tetap putih
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // **Pastikan tetap putih**
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bagian Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.event_note_outlined,
                      color: const Color(0xFF424242), // Warna teks
                      size: 24,
                    ),
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
                    // Tombol Close dengan shadow
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

                // Gambar Status (Berhasil / Gagal)
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
                                ? 'Selamat, Anda berhasil menghapus data kategori produk!'
                                : 'Maaf, Anda belum berhasil menghapus data kategori produk!',
                            textAlign: TextAlign.left,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF757B7B), // Warna teks lebih soft
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

  String getCategoryName(int idCategory) {
    final category = categories.firstWhere(
      (cat) => cat.id_category == idCategory,
      orElse: () => Category(
        id_category: 0,
        name_category: "Tidak diketahui",
        created_at_category: DateTime.now(), // Tambahkan nilai default
        updated_at_category: DateTime.now(), // Tambahkan nilai default
      ),
    );
    return category.name_category;
  }

  @override
  Widget build(BuildContext context) {
    print("Daftar Kategori:");
    for (var cat in categories) {
      print("ID: ${cat.id_category}, Nama: ${cat.name_category}");
    }
    print("ID Kategori Produk: ${product.id_category}");
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nama Produk
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
                    product.name_product,
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

            // Kategori Produk (Sekarang Menampilkan Nama Kategori)
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    color: Color(0xFF757B7B), size: 16),
                const SizedBox(width: 4),
                Text(
                  "Kategori: ${getCategoryName(product.id_category)}", // Gunakan nama kategori
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF757B7B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Harga Produk
            Row(
              children: [
                const Icon(Icons.sell_outlined,
                    color: Color(0xFFD39054), size: 16),
                const SizedBox(width: 4),
                Text(
                  "Rp. ${product.selling_price}",
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
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Membagi dua sisi kiri dan kanan
              children: [
                // Sebelah kiri: Edit & Delete
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        onPressed: () async {
                          await showDialog(
                            context: context,
                            barrierColor: Colors.transparent,
                            builder: (context) =>
                                AddEditProductPage(product: product),
                          );
                          refreshProduct(); // Pastikan daftar produk diperbarui setelah edit
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        onPressed: () async {
                          if (product.id_product == null ||
                              product.id_product!.isEmpty) {
                            showNotificationDialog(context, false);
                            return;
                          }

                          try {
                            String productId = product.id_product!;

                            if (productId == 0) {
                              showNotificationDialog(context, false);
                              return;
                            }

                            int success = await ExcashDatabase.instance
                                .deleteProductById(productId);

                            if (success > 0) {
                              showNotificationDialog(context, true);
                              refreshProduct();
                            } else {
                              showNotificationDialog(context, false);
                            }
                          } catch (e) {
                            print("Error deleting product: $e");
                            showNotificationDialog(context, false);
                          }
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),

                // Sebelah kanan: Stok Produk
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                        onPressed: () {}, // Fungsi pengurangan
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${product.stock}",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
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
                        onPressed: () {}, // Fungsi penambahan
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
