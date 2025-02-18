import 'package:excash/pages/transaction/transaction_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class TransactionCardWidget extends StatelessWidget {
  final String transactionId;
  final List<String> products;
  final String total;
  final String time;

  const TransactionCardWidget({
    super.key,
    required this.transactionId,
    required this.products,
    required this.total,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow("ID Transaksi", transactionId, isBold: false),
              _buildDivider(),
              const SizedBox(height: 4),
              const Text(
                "Produk",
                style: TextStyle(fontSize: 12, color: Color(0xFF757B7B)),
              ),
              const SizedBox(height: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: products.map((product) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      "• $product",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              _buildDivider(),
              _buildRow("Total", total, isTotal: true),
              _buildDivider(),
              _buildRow("Waktu", time),
              _buildDivider(),
              _buildRow2(
                "Action",
                children: Row(
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
                          Icons.receipt_long,
                          color: Color(0xFFD39054),
                          size: 16,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionDetailPage()),
                          );
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
                        onPressed: () async {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value,
      {bool isBold = true, bool isTotal = false, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 100, // Lebar tetap untuk label agar sejajar
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF757B7B)),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: isTotal ? 16 : 14,
                      fontWeight: isTotal
                          ? FontWeight.bold
                          : (isBold ? FontWeight.bold : FontWeight.normal),
                      color: isTotal
                          ? const Color(0xFFD39054)
                          : const Color(0xFF1E1E1E),
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 8), trailing],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow2(String title, {required Widget children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 100, // Lebar tetap agar sejajar dengan _buildRow lainnya
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF757B7B)),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: children, // Menampilkan widget yang diberikan
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      height: 1,
      color: const Color(0xFFE4E4E4),
    );
  }
}
