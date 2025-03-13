import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:excash/widgets/product/product_card_widget.dart';
import 'package:excash/widgets/transaction/transaction_card_widget.dart';
import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late List<TransactionData> _transactions = [];
  var _isLoading = false;

  Future<void> _fetchTransactions() async {
  if (_isLoading) return;  // Jangan biarkan refresh berjalan jika sedang loading
  setState(() => _isLoading = true);
    // Ambil semua transaksi dari database
    final orders = await ExcashDatabase.instance.getAllTransactions();

    // Buat daftar transaksi dengan produk dari tabel order_details
    List<TransactionData> transactions = [];

    for (var order in orders) {
      transactions.add(TransactionData(
        transactionId: order.id_order.toString(),
        total: "Rp. ${order.total_price}",
        time: order.created_at.toString(), // Ubah order_date ke created_at
      ));
    }

    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
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
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Transaksi',
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
                  children: [
                    const Icon(
                      Icons.format_list_bulleted_outlined,
                      color: Color(0xFF1E1E1E),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Transaksi Saya',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _transactions.isEmpty
                      ? const Center(child: Text('Transaksi Kosong'))
                      : RefreshIndicator(
                          onRefresh:
                              _fetchTransactions, // Menambahkan onRefresh
                          child: ListView.builder(
                            itemCount: _transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _transactions[index];
                              return TransactionCardWidget(
                                transactionId: transaction.transactionId,
                                total: transaction.total,
                                time: transaction.time,
                                refreshTransaction: _fetchTransactions,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionData {
  final String transactionId;
  final String total;
  final String time;

  TransactionData({
    required this.transactionId,
    required this.total,
    required this.time,
  });
}
