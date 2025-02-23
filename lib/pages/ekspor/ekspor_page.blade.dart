import 'package:excash/database/excash_database.dart';
import 'package:excash/pages/log/detail_log_page.dart';
import 'package:excash/widgets/log/log_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:excash/pages/product/product_cart_page.dart';

class eksporPage extends StatefulWidget {
  const eksporPage({super.key});

  @override
  State<eksporPage> createState() => _eksporPageState();
}

class _eksporPageState extends State<eksporPage> {
  bool isProductSelected = true;
  bool isTransactionSelected = false;

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
                icon: const Icon(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilihlah data yang ingin di ekspor",
              style: TextStyle(
                color: Color(0xFF1E1E1E),
                fontWeight: FontWeight.w600, // Semi bold
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
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
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text(
                      "Data Produk beserta Kategorinya",
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    value: isProductSelected,
                    onChanged: (value) {
                      setState(() {
                        isProductSelected = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor:
                        Color(0xFF414040), // Warna ketika checkbox dipilih
                    checkColor: Colors.white, // Warna centang dalam checkbox
                    side: const BorderSide(
                      color: Color(0xFF414040), // Warna border
                      width: 1.0, // Ketebalan border
                    ),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      "Data Transaksi",
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    value: isTransactionSelected,
                    onChanged: (value) {
                      setState(() {
                        isTransactionSelected = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor:
                        Color(0xFF414040), // Warna ketika checkbox dipilih
                    checkColor: Colors.white, // Warna centang dalam checkbox
                    side: const BorderSide(
                      color: Color(0xFF414040), // Warna border
                      width: 1.0, // Ketebalan border
                    ),
                  ),
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
                onPressed: () {
                  // Logika ekspor data
                },
                child: const Text(
                  "Ekspor Data",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
