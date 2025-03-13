import 'dart:async';
import 'package:excash/pages/transaction/transaction_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';

class ProductCart2Page extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function onTransactionSuccess;

  ProductCart2Page({
    Key? key,
    required this.cart,
    required this.onTransactionSuccess, // Add this to the constructor
  }) : super(key: key);

  @override
  _ProductCart2PageState createState() => _ProductCart2PageState();
}

class _ProductCart2PageState extends State<ProductCart2Page> {
  Timer? _debounce;
  final TextEditingController paymentController = TextEditingController();

  double payment = 0;
  double change = 0;

  @override
  void dispose() {
    paymentController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getInt('id') ?? 0,
      'name_lengkap': prefs.getString('name_lengkap') ?? "",
      'bisnis_name': prefs.getString('bisnis_name') ?? "",
    };
  }

  int getTotalPrice() {
    return widget.cart.fold(0, (sum, item) {
      final product = item['product'] as Product;
      return sum + (product.price * (item['quantity'] as int)).toInt();
    });
  }

  void calculateChange() {
    setState(() {
      change = (payment - getTotalPrice()).clamp(0, double.infinity);
    });
  }

  void onPaymentChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      setState(() {
        payment = double.tryParse(val) ?? 0;
        calculateChange();
      });
    });
  }

  Future<void> saveTransaction() async {
    // Ambil ID user yang sedang login
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int id = prefs.getInt('id') ?? 0;

    double finalTotal =
        getTotalPrice().toDouble(); // Total harga dari keranjang belanja

    if (payment < finalTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uang kurang!")),
      );
      return;
    }

    // Buat order pertama, dan ambil orderId setelah dibuat
    final order = Order(
      id_order: null,
      id: id, // Menambahkan id_user
      total_product:
          widget.cart.fold(0, (sum, item) => sum + (item['quantity'] as int)),
      total_price:
          finalTotal.toInt(), // Gunakan total_price yang dihitung dengan benar
      payment: payment.toInt(),
      change: change.toInt(),
      created_at: DateTime.now(),
    );

    // Dapatkan orderId setelah membuat order
    int orderId = await ExcashDatabase.instance
        .createOrder(order, []); // Create the order and get orderId

    // Loop melalui cart untuk memeriksa stok dan membuat detail order
    for (var item in widget.cart) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      final price = product.price.toDouble();
      final subtotal = price * quantity; // Menghitung subtotal untuk item ini

      // Simpan detail order dengan subtotal yang dihitung
      await ExcashDatabase.instance.createOrderDetail(
        orderId, // Menggunakan orderId yang dibuat dari fungsi di atas
        int.tryParse(product.id_product!) ?? 0,
        quantity,
        price,
        subtotal,
      );

      // Update stok setelah berhasil menambahkan ke detail order
      int updatedStock = (product.stock - quantity).toInt();
      await ExcashDatabase.instance.updateProductStock(
        int.tryParse(product.id_product!) ?? 0,
        updatedStock,
      );
    }

    // Panggil callback setelah transaksi berhasil
    widget.onTransactionSuccess();

    // Tampilkan pesan sukses setelah menyelesaikan transaksi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Transaksi berhasil!")),
    );
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang Belanja')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("User tidak ditemukan"));
          }

          var userData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Bagian Kasir dan Nama Bisnis (Dua Kolom)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kasir:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(userData['name_lengkap'],
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Nama Bisnis:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(userData['bisnis_name'],
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(), // Garis pemisah

                // Daftar Produk dengan Tiga Kolom (Nama, Jumlah, Harga)
                Expanded(
                  child: Column(
                    children: [
                      // Header untuk daftar produk
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.black, width: 1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Expanded(
                                flex: 3,
                                child: Text("Nama Produk",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 1,
                                child: Text("Jumlah",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center)),
                            Expanded(
                                flex: 2,
                                child: Text("Harga",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.right)),
                          ],
                        ),
                      ),

                      // List produk
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.cart.length,
                          itemBuilder: (context, index) {
                            final item = widget.cart[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child:
                                          Text(item['product'].name_product)),
                                  Expanded(
                                      flex: 1,
                                      child: Text('${item['quantity']}',
                                          textAlign: TextAlign.center)),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          'Rp ${(item['product'].price * item['quantity']).toInt()}',
                                          textAlign: TextAlign.right)),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(), // Garis pemisah

                // Bagian Total Harga (Dua Kolom)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Rp ${getTotalPrice()}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 10),

                // Input Uang Pelanggan
                TextFormField(
                  controller: paymentController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Uang Pelanggan",
                    labelStyle:
                        TextStyle(color: Color(0xFFD39054)), // Warna label
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xFFD39054),
                          width: 2.0), // Warna ketika diinputkan
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.purple,
                          width: 1.5), // Warna default (ungu)
                    ),
                  ),
                  onChanged: onPaymentChanged,
                  style: TextStyle(color: Colors.black), // Warna teks input
                ),

                const SizedBox(height: 24),

                // Bagian Kembalian (Dua Kolom)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kembalian:",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Rp ${change.toInt()}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),

                const SizedBox(height: 24),

                // Tombol Simpan Transaksi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Simpan Transaksi"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
