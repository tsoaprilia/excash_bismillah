import 'package:flutter/material.dart';

class LogDetailPage extends StatefulWidget {
  final String id;
  final String date;
  final String type;
  final String user;
  final String email;

  const LogDetailPage({
    super.key,
    required this.id,
    required this.date,
    required this.type,
    required this.user,
    required this.email,
  });

  @override
  State<LogDetailPage> createState() => _LogDetailPageState();
}

class _LogDetailPageState extends State<LogDetailPage> {
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
            const Expanded(
              child: Text(
                "Detail Aktivitas",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Aktivitas User",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildRow("Id Aktivitas", widget.id),
                  const Divider(),
                  _buildRow("Username User", widget.user),
                  const Divider(),
                  _buildRow("Email", widget.email),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    "Pembayaran",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  _buildRow("Waktu Aktivitas", widget.date),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    "Aksi User",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  _buildActionRow("Type", widget.type),
                  const Divider(),
                  _buildRow("Operasi", "Produk"),
                  const Divider(),
                  _buildRow("Status", "Sukses", isHighlighted: true),
                  const Divider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget untuk menampilkan baris informasi
  Widget _buildRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1817174)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? Color(0xFFD39054): Color(0xFF1817174),
            ),
          ),
        ],
      ),
    );
  }

  /// Fungsi untuk mendapatkan warna latar belakang berdasarkan tipe
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'delete':
        return const Color(0xFFFFE6E6); // Merah muda untuk Delete
      case 'edit':
        return const Color(0xFFFFF2CC); // Kuning untuk Edit
      case 'add':
        return const Color(0xFFE6F7E6); // Hijau untuk Add
      default:
        return Colors.grey.shade200; // Default abu-abu
    }
  }

  /// Fungsi untuk mendapatkan warna teks berdasarkan tipe
  Color _getTextColor(String type) {
    switch (type.toLowerCase()) {
      case 'delete':
        return Colors.red; // Merah untuk Delete
      case 'edit':
        return const Color(0xFFD39054); // Coklat untuk Edit
      case 'add':
        return Colors.green; // Hijau untuk Add
      default:
        return Colors.black; // Default hitam
    }
  }

  /// Widget untuk menampilkan baris informasi dengan background warna sesuai tipe
  Widget _buildActionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1817174)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor(value), // Warna background berdasarkan tipe
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTextColor(value), // Warna teks berdasarkan tipe
              ),
            ),
          ),
        ],
      ),
    );
  }

}
