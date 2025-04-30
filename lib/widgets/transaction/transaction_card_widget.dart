import 'package:flutter/material.dart';
import 'package:excash/pages/transaction/transaction_detail_page.dart';
import 'package:intl/intl.dart';

class TransactionCardWidget extends StatelessWidget {
  final String transactionId;
  final String total;
  final String time;
  final VoidCallback refreshTransaction;

  const TransactionCardWidget({
    super.key,
    required this.transactionId,
    required this.total,
    required this.time,
    required this.refreshTransaction,
  });

  String formatTanggal(String time) {
    try {
      DateTime dateTime = DateTime.parse(time);
      return DateFormat('yyyy-MM-dd / HH:mm').format(dateTime);
    } catch (e) {
      return time;
    }
  }

  String formatRupiah(String value) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    // Bersihkan karakter non-digit, termasuk "Rp", spasi, titik, dll.
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    int parsed = int.tryParse(cleaned) ?? 0;
    return 'Rp ${formatter.format(parsed)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow("ID Transaksi", transactionId),
          _buildDivider(),
          _buildRow("Total", formatRupiah(total), isTotal: true),
          _buildDivider(),
          _buildRow("Waktu", formatTanggal(time), isWrap: true),
          _buildDivider(),
          _buildRow(
            "Action",
            "",
            trailing: Wrap(
              spacing: 8,
              children: [
                _buildIconButton(
                  icon: Icons.receipt_long,
                  color: const Color(0xFFD39054),
                  bgColor: const Color(0xFFF2DECC),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TransactionDetailPage(orderId: int.parse(transactionId)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String title, String value,
      {bool isBold = true, bool isTotal = false, Widget? trailing, bool isWrap = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: Color(0xFF757B7B)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: isWrap
                  ? Wrap(
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: isTotal ? 16 : 14,
                            fontWeight: isTotal
                                ? FontWeight.bold
                                : (isBold ? FontWeight.bold : FontWeight.normal),
                            color: isTotal ? const Color(0xFFD39054) : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontSize: isTotal ? 16 : 14,
                        fontWeight: isTotal
                            ? FontWeight.bold
                            : (isBold ? FontWeight.bold : FontWeight.normal),
                        color: isTotal ? const Color(0xFFD39054) : const Color(0xFF1E1E1E),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 16),
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
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
