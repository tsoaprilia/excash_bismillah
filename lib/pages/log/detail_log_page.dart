import 'package:flutter/material.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/log.dart';
import 'package:intl/intl.dart';

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
  LogActivity? _logDetail;

  @override
  void initState() {
    super.initState();
    _fetchLogDetail();
  }

  Future<void> _fetchLogDetail() async {
    try {
      final log = await ExcashDatabase.instance.getLogById(widget.id);
      setState(() {
        _logDetail = log;
      });
    } catch (e) {
      print('Error fetching log detail: $e');
    }
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('d MMMM yyyy, HH:mm').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_logDetail == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 24, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
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
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
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
                  _buildRow("Id Aktivitas", _logDetail!.id_log.toString()),
                  const Divider(),
                  _buildRow("Username User", _logDetail!.user),
                  const Divider(),
                  _buildRow("Email", _logDetail!.email),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    "Pembayaran",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  _buildRow("Waktu Aktivitas", _formatDate(_logDetail!.date)),
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
                  
                  _buildRow("Old Value", _logDetail!.oldValue ?? "N/A"),
                  const Divider(),
                  _buildRow("New Value", _logDetail!.newValue ?? "N/A"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

/// Widget for displaying the action row
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
              color: _getTypeColor(value), // Background color based on type
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getTextColor(value), // Text color based on type
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'delete':
        return const Color(0xFFFFE6E6);
      case 'edit':
        return const Color(0xFFFFF2CC);
      case 'add':
        return const Color(0xFFE6F7E6);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor(String type) {
    switch (type.toLowerCase()) {
      case 'delete':
        return Colors.red;
      case 'edit':
        return const Color(0xFFD39054);
      case 'add':
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
