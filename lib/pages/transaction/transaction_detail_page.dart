import 'package:flutter/material.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({super.key});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
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
            // Tombol Back dengan Shadow
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 24, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // Title di Tengah
            const Expanded(
              child: Text(
                "Detail Transaksi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Spacer untuk keseimbangan layout (agar tombol back tidak mendorong title)
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Detail Order",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildRow("Id Transaksi", "1770546017887890"),
                      _buildRow("Nama Kasir", "Aprilia Dwi Cristyana"),
                      _buildRow("Waktu Order", "14/06/2024  16:50"),
                      const SizedBox(height: 12),
                      const Text(
                        "Produk",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      _buildRow("Buku B5", "2"),
                      _buildRow("Pensil 2B Joyko", "2"),
                      const SizedBox(height: 12),
                      _buildRow("Subtotal", "Rp. 30.000", isBold: true),
                      _buildRow("Diskon", "Rp. 2.000"),
                      const Divider(),
                      _buildRow("Total", "Rp. 28.000",
                          isBold: true, isHighlighted: true),
                      const SizedBox(height: 12),
                      const Text(
                        "Pembayaran",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      _buildRow("Uang Diterima", "Rp. 50.000"),
                      _buildRow("Kembalian", "Rp. 20.000"),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildPrintButton(),
          ),
        ],
      ),
    );
  } // Implementasi selanjutnya
}

/// Tombol simpan kategori
Widget _buildPrintButton() {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: () async {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text(
        "Print Struk",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget _buildRow(String label, String value,
    {bool isBold = false, bool isHighlighted = false}) {
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
            color: isHighlighted ? Colors.orange : Colors.black87,
          ),
        ),
      ],
    ),
  );
}
