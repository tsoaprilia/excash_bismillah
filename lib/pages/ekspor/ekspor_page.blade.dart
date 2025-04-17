import 'package:excash/pages/ekspor/categorydata.dart';
import 'package:flutter/material.dart';
import 'package:excash/pages/ekspor/productdata.dart';
import 'package:excash/pages/ekspor/userdata.dart';
import 'package:excash/pages/ekspor/orderdata.dart';
import 'package:excash/pages/ekspor/oderderdetaildata.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  // State checkbox untuk tiap tabel
  bool isCategorySelected = false;
  bool isProductSelected = false;
  bool isUserSelected = false;
  bool isOrderSelected = false;
  bool isOrderDetailSelected = false;

  final categoryData= CategoryData(); // kategori
  final productData = ProductData(); // produk
  final userData = UserData(); // user
  final orderData = OrderData(); // order
  final orderDetailData = OrderDetailData(); // detail order

  Future<void> _exportSelectedData() async {
    if (!isCategorySelected &&
        !isProductSelected &&
        !isUserSelected &&
        !isOrderSelected &&
        !isOrderDetailSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan pilih minimal satu data untuk diekspor!")),
      );
      return;
    }

    if (isCategorySelected) {
      await categoryData.exportToCSV();
    }
    if (isProductSelected) {
      await productData.exportToCSV();
    }
    if (isUserSelected) {
      await userData.exportToCSV();
    }
    if (isOrderSelected) {
      await orderData.exportToCSV();
    }
    if (isOrderDetailSelected) {
      await orderDetailData.exportToCSV();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil diekspor!")),
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
              width: 48,
              height: 48,
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
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              "Ekspor Data",
              style: TextStyle(
                color: Color(0xFF424242),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCheckbox("Data Kategori", isCategorySelected, (val) {
                    setState(() => isCategorySelected = val!);
                  }),
                  _buildCheckbox("Data Produk", isProductSelected, (val) {
                    setState(() => isProductSelected = val!);
                  }),
                  _buildCheckbox("Data Pengguna", isUserSelected, (val) {
                    setState(() => isUserSelected = val!);
                  }),
                  _buildCheckbox("Data Order", isOrderSelected, (val) {
                    setState(() => isOrderSelected = val!);
                  }),
                  _buildCheckbox("Detail Order", isOrderDetailSelected, (val) {
                    setState(() => isOrderDetailSelected = val!);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _exportSelectedData,
                child: const Text(
                  "Export Data Terpilih",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF414040),
      checkColor: Colors.white,
      side: const BorderSide(color: Color(0xFF414040), width: 1.0),
    );
  }
}
