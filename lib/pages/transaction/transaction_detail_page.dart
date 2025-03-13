import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/models/user.dart';
import 'package:flutter/material.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/order.dart';

class TransactionDetailPage extends StatefulWidget {
  final int orderId;
  const TransactionDetailPage({Key? key, required this.orderId}) : super(key: key);

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late Future<Order> order;
  late Future<List<Map<String, dynamic>>> orderDetails;
  late Future<User?> user;
  BlueThermalPrinter printer = BlueThermalPrinter.instance;

  @override
  void initState() {
    super.initState();
    order = ExcashDatabase.instance.getOrderById(widget.orderId);
    orderDetails = fetchOrderDetails(widget.orderId);
    order.then((orderData) {
      user = ExcashDatabase.instance.getUserById(orderData.id);
      setState(() {});
    });
  }

  /// Ambil detail order dengan JOIN produk untuk mendapatkan nama produk
  Future<List<Map<String, dynamic>>> fetchOrderDetails(int orderId) async {
    final db = await ExcashDatabase.instance.database;
    return await db.rawQuery('''
      SELECT od.*, p.name_product AS nama_produk
      FROM $tableOrderDetail od
      JOIN $tableProduct p ON od.id_product = p.id_product
      WHERE od.id_order = ?
    ''', [orderId]);
  }

  /// Fungsi cetak struk
  void _printReceipt(Order orderData, User userData, List<Map<String, dynamic>> orderDetailsData) async {
    if ((await printer.isConnected)!) {
      printer.printNewLine();
      printer.printCustom('TOKO ${userData.businessName}', 2, 1);
      printer.printCustom('Kasir: ${userData.fullName}', 1, 1);
      printer.printNewLine();
      printer.printCustom('Detail Transaksi', 1, 1);
      printer.printNewLine();

      printer.printLeftRight('Nama Produk', 'Qty | Subtotal', 1);
      printer.printNewLine();
      for (var detail in orderDetailsData) {
        printer.printLeftRight(
          '${detail['nama_produk']}', 
          '${detail['quantity']} | Rp ${detail['subtotal'].toInt()}', 
          1
        );
      }
      printer.printNewLine();
      printer.printLeftRight('Subtotal', 'Rp ${orderData.total_price}', 1);
      printer.printLeftRight('Total', 'Rp ${orderData.total_price}', 2);
      printer.printLeftRight('Uang Diterima', 'Rp ${orderData.payment}', 1);
      printer.printLeftRight('Kembalian', 'Rp ${orderData.change}', 1);
      printer.printNewLine();
      printer.printNewLine();
      printer.paperCut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Transaksi"),
      ),
      body: FutureBuilder<Order>(
        future: order,
        builder: (context, orderSnapshot) {
          if (orderSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!orderSnapshot.hasData) {
            return const Center(child: Text("Order tidak ditemukan"));
          }

          final orderData = orderSnapshot.data!;

          return FutureBuilder<User?>(
            future: user,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!userSnapshot.hasData || userSnapshot.data == null) {
                return const Center(child: Text("User tidak ditemukan"));
              }

              final userData = userSnapshot.data!;

              return FutureBuilder<List<Map<String, dynamic>>>(
                future: orderDetails,
                builder: (context, orderDetailSnapshot) {
                  if (orderDetailSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!orderDetailSnapshot.hasData || orderDetailSnapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada detail order"));
                  }

                  final orderDetailsData = orderDetailSnapshot.data!;

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Toko ${userData.businessName}",
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Kasir: ${userData.fullName}"),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text("Produk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Table(
                            border: TableBorder.all(color: Colors.black12),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(2),
                            },
                            children: [
                              _buildTableHeader(),
                              ...orderDetailsData
                                  .map((detail) => _buildTableRow(detail))
                                  .toList(),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildRow("Subtotal", "Rp ${orderData.total_price}"),
                          const Divider(),
                          _buildRow2("Total", "Rp ${orderData.total_price}",
                              isBold: true, textColor: const Color(0xFFD39054)),
                          _buildRow("Uang Diterima", "Rp ${orderData.payment}"),
                          _buildRow("Kembalian", "Rp ${orderData.change}"),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _printReceipt(orderData, userData, orderDetailsData),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E1E1E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text("Print Struk"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      children: [
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Nama Produk",
                style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Subtotal",
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> detail) {
    return TableRow(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(detail['nama_produk'])), // Nama Produk
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(detail['quantity'].toString())),
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Rp ${detail['subtotal'].toInt()}")),
      ],
    );
  }
}


  TableRow _buildTableHeader() {
    return const TableRow(
      children: [
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("ID Produk",
                style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Subtotal",
                style: TextStyle(fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow2(String label, String value,
      {bool isBold = false, bool isHighlighted = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color:
                  textColor ?? (isHighlighted ? Colors.orange : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
