import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:excash/pages/transaction/print.dart';
import 'package:excash/widgets/product/product_card_widget.dart';
import 'package:excash/widgets/transaction/transaction_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String? _fullName;
  late List<TransactionData> _transactions = [];
  var _isLoading = false;

  final TextEditingController _searchController = TextEditingController();
  List<TransactionData> _filteredTransactions = [];

  Future<void> _getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('user_username') ??
          'Guest'; // Ambil dari key yang benar
    });
  }

  void _filterTransactionsById(String query) {
    final filtered = _transactions.where((transaction) {
      return transaction.transactionId.contains(query);
    }).toList();

    setState(() {
      _filteredTransactions = filtered;
    });
  }

  Future<void> _fetchTransactions() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    final orders = await ExcashDatabase.instance.getAllTransactions();

    List<TransactionData> transactions = orders.map((order) {
      return TransactionData(
        transactionId: order.id_order.toString(),
        total: "Rp. ${order.total_price}",
        time: order.created_at.toString(),
      );
    }).toList();

    setState(() {
      _transactions = transactions;
      _filteredTransactions = transactions; // set awal data hasil filter
      _isLoading = false;
    });
  }

// Di halaman Transaksi
  void refreshTransaction() async {
    setState(() async {
      _transactions = (await ExcashDatabase.instance.getAllTransactions())
          .cast<TransactionData>(); // Muat ulang data transaksi
    });
  }

  @override
  void initState() {
    super.initState();
    refreshTransaction();
    _fetchTransactions();
    _getFullName();
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
            Container(
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
                controller: _searchController,
                onChanged: _filterTransactionsById, // trigger filter tiap ketik
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
              child: RefreshIndicator(
                onRefresh: _fetchTransactions,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTransactions.isEmpty
                        ? ListView(
                            // Membuat ListView kosong agar bisa swipe refresh
                            children: const [
                              SizedBox(
                                height: 200,
                                child: Center(child: Text('Transaksi Kosong')),
                              )
                            ],
                          )
                        : ListView.builder(
                            itemCount: _filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = _filteredTransactions[index];
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
