import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:excash/pages/impor/importdata.dart';
import 'package:excash/database/excash_database.dart';

class ImporPage extends StatefulWidget {
  const ImporPage({super.key});

  @override
  State<ImporPage> createState() => _ImporPageState();
}

class _ImporPageState extends State<ImporPage> {
  File? userFile;
  File? categoryFile;
  File? productFile;
  File? orderFile;
  File? orderDetailFile;

Future<void> pickFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        if (fileType == 'user') {
          userFile = File(result.files.single.path!);
        } else if (fileType == 'category') {
          categoryFile = File(result.files.single.path!);
        } else if (fileType == 'product') {
          productFile = File(result.files.single.path!);
        } else if (fileType == 'order') {
          orderFile = File(result.files.single.path!);
        } else if (fileType == 'orderDetail') {
          orderDetailFile = File(result.files.single.path!);
        }
      });
    }
  }
  // Refresh methods
  Future<void> _refreshUsers() async {
    await printAllUsers();
  }

  Future<void> _refreshCategory() async {
    await printCategoryData();
  }

  Future<void> _refreshProducts() async {
    await printProductData();
  }

  Future<void> _refreshOrders() async {
    await printOrderData();
  }

  Future<void> _refreshOrderDetails() async {
    await printOrderDetailData();
  }

  Future<void> importData() async {
    final importData = ImportData();

    if (userFile != null) {
      await importData.importFromCSV(userFile!, 'users');
      await printAllUsers();
      _refreshUsers();  // Refresh after importing user data
    }
    if (categoryFile != null) {
      await importData.importFromCSV(categoryFile!, 'category');
      await printCategoryData();
      _refreshCategory();  // Refresh after importing category data
    }
    if (productFile != null) {
      await importData.importFromCSV(productFile!, 'product');
      await printProductData();
      _refreshProducts();  // Refresh after importing product data
    }
    if (orderFile != null) {
      await importData.importFromCSV(orderFile!, 'orders');
      await printOrderData(); // Debugging log
      _refreshOrders();  // Refresh after importing order data
    }
    if (orderDetailFile != null) {
      await importData.importFromCSV(orderDetailFile!, 'order_detail');
      await printOrderDetailData(); // Debugging log
      _refreshOrderDetails();  // Refresh after importing order details data
    }

    // Show success message after import
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil diimpor!")),
    );
  }

  // Print functions
  Future<void> printAllUsers() async {
    final db = await ExcashDatabase.instance.database;
    List<Map<String, dynamic>> users = await db.query('users');
    print("Isi tabel users:");
    if (users.isNotEmpty) {
      users.forEach((user) {
        print("ID: ${user['id']}");
        print("Email: ${user['email']}");
        print("Full Name: ${user['full_name']}");
        print("Business Name: ${user['business_name']}");
        print("Password: ${user['password']}");
        print("Image: ${user['image'] ?? 'N/A'}");
        print("------------------------------");
      });
    } else {
      print("Tabel users kosong.");
    }
  }

  Future<void> printCategoryData() async {
    final db = await ExcashDatabase.instance.database;
    List<Map<String, dynamic>> categories = await db.query('category');

    print("Isi tabel category:");
    if (categories.isNotEmpty) {
      categories.forEach((category) {
        print("ID Category: ${category['id_category']}");
        print("ID: ${category['id']}");
        print("Name: ${category['name_category']}");
        print("Created At: ${category['created_at_category']}");
        print("Updated At: ${category['updated_at_category'] ?? 'N/A'}");
        print("------------------------------");
      });
    } else {
      print("Tabel category kosong.");
    }
  }

  Future<void> printProductData() async {
    final db = await ExcashDatabase.instance.database;
    List<Map<String, dynamic>> products = await db.query('product');

    print("Isi tabel product:");
    if (products.isNotEmpty) {
      products.forEach((product) {
        print("ID Product: ${product['id_product']}");
        print("ID: ${product['id']}");
        print("Category ID: ${product['id_category']}");
        print("Name: ${product['name_product']}");
        print("Price: ${product['price']}");
        print("Selling Price: ${product['selling_price']}");
        print("Stock: ${product['stock']}");
        print("Description: ${product['description']}");
        print("Created At: ${product['created_at']}");
        print("Updated At: ${product['updated_at']}");
        print("------------------------------");
      });
    } else {
      print("Tabel product kosong.");
    }
  }

  Future<void> printOrderData() async {
    final db = await ExcashDatabase.instance.database;
    List<Map<String, dynamic>> orders = await db.query('orders');

    print("Isi tabel orders:");
    if (orders.isNotEmpty) {
      orders.forEach((order) {
        print("ID Order: ${order['id_order']}");
        print("User ID: ${order['id']}");
        print("Total Product: ${order['total_product']}");
        print("Total Price: ${order['total_price']}");
        print("Payment: ${order['payment']}");
        print("Change: ${order['change']}");
        print("Created At: ${order['created_at']}");
        print("------------------------------");
      });
    } else {
      print("Tabel orders kosong.");
    }
  }

  Future<void> printOrderDetailData() async {
    final db = await ExcashDatabase.instance.database;
    List<Map<String, dynamic>> orderDetails = await db.query('order_detail');

    print("Isi tabel order_detail:");
    if (orderDetails.isNotEmpty) {
      orderDetails.forEach((orderDetail) {
        print("ID Order Detail: ${orderDetail['id_order_detail']}");
        print("Order ID: ${orderDetail['id_order']}");
        print("Product ID: ${orderDetail['id_product']}");
        print("Quantity: ${orderDetail['quantity']}");
        print("Price: ${orderDetail['price']}");
        print("Subtotal: ${orderDetail['subtotal']}");
        print("------------------------------");
      });
    } else {
      print("Tabel order_detail kosong.");
    }
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
          mainAxisAlignment: MainAxisAlignment.start,
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
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Impor Data",
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Upload section for each data type
            _buildUploadSection("Upload file User", userFile, 'user'),
            _buildUploadSection(
                "Upload file Category", categoryFile, 'category'),
            _buildUploadSection("Upload file Product", productFile, 'product'),
            _buildUploadSection("Upload file Order", orderFile, 'order'),
            _buildUploadSection(
                "Upload file Order Detail", orderDetailFile, 'orderDetail'),
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
                onPressed:
                    importData, // Memanggil importData untuk memulai impor dan cek data
                child: const Text(
                  "Impor Data",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bagian untuk memilih file
  Widget _buildUploadSection(String title, File? file, String fileType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => pickFile(fileType),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD39054), width: 1.5),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  file != null
                      ? file.path.split('/').last
                      : "File Belum Dipilih",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF757B7B)),
                ),
                Text(
                  file != null ? "File dipilih" : "Seret atau pilih file",
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF757B7B)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFD39054), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.add, color: Color(0xFFD39054), size: 20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
