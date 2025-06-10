import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/transaction/transaction_detail_page.dart';

class ProductCart2Page extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Function onTransactionSuccess;

  const ProductCart2Page({
    Key? key,
    required this.cart,
    required this.onTransactionSuccess,
  }) : super(key: key);

  @override
  _ProductCart2PageState createState() => _ProductCart2PageState();
}

class _ProductCart2PageState extends State<ProductCart2Page> {
  Timer? _debounce;
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final FocusNode _paymentFocusNode = FocusNode();

  double payment = 0;
  double change = 0;
  double discountValue = 0;

  final _idr = NumberFormat('#,##0', 'id_ID');
  String fRp(int value) => _idr.format(value);

  @override
  void initState() {
    super.initState();
    // Baris ini dikomentari/dihapus untuk mencegah keyboard muncul secara otomatis
    // dan berpotensi menyebabkan masalah fokus/layout di awal.
    // Biarkan pengguna mengetuk input secara manual.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   FocusScope.of(context).requestFocus(_paymentFocusNode);
    // });
  }

  @override
  void dispose() {
    _paymentFocusNode.dispose();
    paymentController.dispose();
    discountController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('id') ?? 'unknown',
      'user_username': prefs.getString('user_username') ?? "",
      'bisnis_name': prefs.getString('bisnis_name') ?? "",
      'bisnis_address': prefs.getString('bisnis_address') ?? "",
      'user_npwp': prefs.getString('user_npwp') ?? "",
    };
  }

  int getTotalPrice() {
    return widget.cart.fold(0, (sum, item) {
      final product = item['product'] as Product;
      return sum + (product.selling_price * (item['quantity'] as int)).toInt();
    });
  }

  void calculateChange() {
    setState(() {
      change = (payment - getTotalPrice()).clamp(0, double.infinity);
    });
  }

  void onPaymentChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        payment = double.tryParse(val) ?? 0;
        calculateChange();
      });
    });
  }

  void onDiscountChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        discountValue = double.tryParse(val) ?? 0;
        calculateChange();
      });
    });
  }

  Future<void> saveTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? 'unknown';

    double finalTotal = getTotalPrice().toDouble();

    if (payment < finalTotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uang kurang!")),
      );
      return;
    }

    final order = Order(
      id_order: null,
      id: id,
      total_product:
          widget.cart.fold(0, (sum, item) => sum + (item['quantity'] as int)),
      total_price: finalTotal.toInt(),
      payment: payment.toInt(),
      change: change.toInt(),
      created_at: DateTime.now(),
    );

    int orderId = await ExcashDatabase.instance.createOrder(order, []);

    for (var item in widget.cart) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      final price = product.price.toDouble();
      final subtotal = price * quantity;

      await ExcashDatabase.instance.createOrderDetail(
        orderId,
        int.tryParse(product.id_product!) ?? 0,
        quantity,
        price,
        subtotal,
      );

      int updatedStock = product.stock - quantity;
      await ExcashDatabase.instance.updateProductStock(
        product.id_product,
        updatedStock,
      );
    }

    widget.onTransactionSuccess();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaksi berhasil!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailPage(orderId: orderId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // PENTING: Mengatur ini ke `false` mencegah `Scaffold` mengubah ukurannya
      // saat keyboard muncul. Ini adalah solusi utama untuk masalah layout/fokus.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Keranjang Belanja",
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("User tidak ditemukan"));
          }

          var userData = snapshot.data!;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              // Baris ini dihapus untuk mengeliminasi potensi dismiss keyboard
              // yang tidak disengaja akibat interaksi gulir yang sensitif.
              // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kasir dan Bisnis
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kasir:",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(userData['user_username'],
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
                  const Divider(),

                  // Header Produk
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text("Nama Produk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("Subtotal",
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.right),
                        ),
                      ],
                    ),
                  ),

                  // Daftar Produk
                  Column(
                    children: widget.cart.map((item) {
                      final product = item['product'] as Product;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(product.name_product),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                  '${item['quantity']} x Rp ${fRp(product.selling_price)}',
                                  textAlign: TextAlign.center),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Rp ${fRp((product.selling_price * item['quantity']).toInt())}',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),

                  const Divider(),

                  // Total Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Rp ${fRp(getTotalPrice())}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // MODIFIKASI PENTING DI SINI:
                  // Input Pembayaran dibungkus dengan GestureDetector dan AbsorbPointer
                  GestureDetector(
                    onTap: () {
                      // Ini akan secara eksplisit meminta fokus pada TextFormField
                      FocusScope.of(context).requestFocus(_paymentFocusNode);
                      // Anda bisa mencoba menambahkan ini jika requestFocus saja tidak cukup,
                      // tetapi ini lebih sering menyebabkan masalah daripada memecahkan.
                      // Coba tanpa ini terlebih dahulu.
                      // SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    child: AbsorbPointer(
                      // AbsorbPointer mencegah TextFormField dari menangani tap-nya sendiri,
                      // sehingga GestureDetector di atasnya yang akan mengambil alih.
                      child: TextFormField(
                        controller: paymentController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Masukkan Uang Pelanggan",
                          labelStyle: TextStyle(color: Color(0xFFD39054)),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFFD39054), width: 2.0),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.purple, width: 1.5),
                          ),
                        ),
                        onChanged: onPaymentChanged,
                        style: const TextStyle(color: Colors.black),
                        focusNode: _paymentFocusNode, // Pastikan focusNode disetel
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kembalian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kembalian:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("Rp ${fRp(change.toInt())}",
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
            ),
          );
        },
      ),
    );
  }
}