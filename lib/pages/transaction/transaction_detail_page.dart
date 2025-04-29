import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:excash/general_pages/menu.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/models/user.dart';
import 'package:flutter/material.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/order.dart';
import 'package:intl/intl.dart';

class TransactionDetailPage extends StatefulWidget {
  final int orderId;
  const TransactionDetailPage({Key? key, required this.orderId})
      : super(key: key);

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

  String formatTanggal(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd / HH:mm').format(dateTime);
  }

  /// Ambil detail order dengan JOIN produk untuk mendapatkan nama produk dan harga satuan
  Future<List<Map<String, dynamic>>> fetchOrderDetails(int orderId) async {
    final db = await ExcashDatabase.instance.database;
    return await db.rawQuery('''
    SELECT od.*, p.name_product AS nama_produk, p.price AS harga_satuan
    FROM $tableOrderDetail od
    JOIN $tableProduct p ON od.id_product = p.id_product
    WHERE od.id_order = ?
  ''', [orderId]);
  }

  /// Fungsi cetak struk
  void _printReceipt(Order orderData, User userData,
      List<Map<String, dynamic>> orderDetailsData, BuildContext context) async {
    if ((await printer.isConnected)!) {
      try {
        printer.printNewLine();
        printer.printCustom('TOKO ${userData.businessName}', 1, 1);
        printer.printCustom('oleh excash', 1, 1);

        printer.printNewLine();
        printer.printCustom(
            'Waktu: ${formatTanggal(orderData.created_at)}', 1, 1);
        printer.printCustom('Kasir: ${userData.fullName}', 1, 1);

        printer.printCustom('--------------------------------', 1, 1);
        printer.printNewLine();
        printer.printCustom('Detail', 1, 1);
        printer.printCustom('--------------------------------', 1, 1);

        for (var detail in orderDetailsData) {
          printer.printLeftRight(
            '${detail['nama_produk']}',
            '${detail['quantity']}x${detail['harga_satuan'].toInt()} ${detail['subtotal'].toInt()}',
            1,
          );
        }

        printer.printCustom('--------------------------------', 1, 1);
        printer.printLeftRight('Total', 'Rp ${orderData.total_price}', 1);
        printer.printCustom('--------------------------------', 1, 1);

        printer.printNewLine();
        printer.printLeftRight('Uang Diterima', 'Rp ${orderData.payment}', 1);
        printer.printLeftRight('Kembalian', 'Rp ${orderData.change}', 1);
        printer.printCustom('--------------------------------', 1, 1);

        printer.printNewLine();
        printer.printNewLine();
        printer.printCustom('TERIMA KASIH!', 2, 1);
        printer.printCustom('Simpan struk ini', 1, 1);
        printer.printCustom('sebagai bukti pembayaran', 1, 1);
        printer.printNewLine();
        printer.printNewLine();
        printer.printNewLine();
        printer.paperCut();

        // TAMPILKAN ALERT BERHASIL
        showPrintDialog(
          context,
          isSuccess: true,
          title: 'Struk Berhasil Diprint',
          message: 'Struk transaksi berhasil dicetak!',
        );
      } catch (e) {
        // TAMPILKAN ALERT GAGAL
        showPrintDialog(
          context,
          isSuccess: false,
          title: 'Struk Gagal Diprint',
          message: 'Terjadi masalah saat mencetak struk: ${e.toString()}',
        );
      }
    } else {
      // TAMPILKAN ALERT PRINTER BELUM TERHUBUNG
      showPrintDialog(
        context,
        isSuccess: false,
        title: 'Printer Belum Terkoneksi',
        message: 'Silakan sambungkan printer, pada menu "Print" di profile!',
      );
    }
  }

  void showPrintDialog(BuildContext context,
      {required bool isSuccess,
      required String title,
      required String message}) {
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
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 16.0, bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.print_outlined,
                        color: const Color(0xFF424242), size: 24),
                    Expanded(
                      child: Text(
                        title,
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
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF424242),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            message,
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: Colors.black),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainScreen(
                          initialIndex: 3), // langsung ke TransactionPage
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ),
            const SizedBox(width: 12), // Jarak antara ikon dan teks
            const Text(
              "Detail Transaksi",
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
                  if (orderDetailSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!orderDetailSnapshot.hasData ||
                      orderDetailSnapshot.data!.isEmpty) {
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text("Kasir: ${userData.fullName}"),
                          Text(
                              "Tanggal Transaksi: ${formatTanggal(orderData.created_at)}"),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text("Produk",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Table(
                            border: TableBorder.all(color: Colors.black12),
                            columnWidths: const {
                              0: FlexColumnWidth(2),
                              1: FlexColumnWidth(2),
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
                              onPressed: () => _printReceipt(orderData,
                                  userData, orderDetailsData, context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E1E1E),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
          child: Text(detail['nama_produk']), // Nama Produk
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
              "${detail['quantity'].toString()} x Rp ${detail['harga_satuan'].toInt()}"), // Quantity
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Rp ${detail['subtotal'].toInt()}"), // Subtotal
        ),
      ],
    );
  }
}

TableRow _buildTableHeader() {
  return const TableRow(
    children: [
      Padding(
          padding: EdgeInsets.all(8.0),
          child:
              Text("ID Produk", style: TextStyle(fontWeight: FontWeight.bold))),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
      Padding(
          padding: EdgeInsets.all(8.0),
          child:
              Text("Subtotal", style: TextStyle(fontWeight: FontWeight.bold))),
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
