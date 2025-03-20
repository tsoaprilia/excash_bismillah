import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ExportData {
  Future<void> exportToCSV() async {
    Database db = await ExcashDatabase.instance.database;

    // Pastikan ada izin penyimpanan
    if (await Permission.storage.request().isDenied) {
      print("Izin penyimpanan ditolak!");
      return;
    }

    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/excash_export.csv';

    List<List<dynamic>> csvData = [];

    // Ekspor Tabel Category
    List<Map<String, dynamic>> categories = await db.query('category');
    if (categories.isNotEmpty) {
      csvData.add(['id_category', 'name_category', 'created_at', 'updated_at']);
      for (var row in categories) {
        csvData.add([
          row['id_category'],
          row['name_category'],
          row['created_at_category'],
          row['updated_at_category'] ?? ''
        ]);
      }
    }

    // Ekspor Tabel Product
    List<Map<String, dynamic>> products = await db.query('product');
    if (products.isNotEmpty) {
      csvData.add([
        'id_product',
        'id_category',
        'name_product',
        'price',
        'selling_price',
        'stock',
        'description',
        'created_at',
        'updated_at'
      ]);
      for (var row in products) {
        csvData.add([
          row['id_product'],
          row['id_category'],
          row['name_product'],
          row['price'],
          row['selling_price'],
          row['stock'],
          row['description'],
          row['created_at'],
          row['updated_at']
        ]);
      }
    }

    // Ekspor Tabel User
    List<Map<String, dynamic>> users = await db.query('user');
    if (users.isNotEmpty) {
      csvData.add(
          ['id', 'email', 'fullName', 'businessName', 'password', 'image']);
      for (var row in users) {
        csvData.add([
          row['id'],
          row['email'],
          row['fullName'],
          row['businessName'],
          row['password'],
          row['image'] ?? ''
        ]);
      }
    }

    // Ekspor Tabel Orders
    List<Map<String, dynamic>> orders = await db.query('orders');
    if (orders.isNotEmpty) {
      csvData.add([
        'id_order',
        'id_user',
        'total_product',
        'total_price',
        'payment',
        'change',
        'created_at'
      ]);
      for (var row in orders) {
        csvData.add([
          row['id_order'],
          row['id'],
          row['total_product'],
          row['total_price'],
          row['payment'],
          row['change'],
          row['created_at']
        ]);
      }
    }

    // Ekspor Tabel OrderDetail
    List<Map<String, dynamic>> orderDetails = await db.query('order_detail');
    if (orderDetails.isNotEmpty) {
      csvData.add([
        'id_order_detail',
        'id_order',
        'id_product',
        'quantity',
        'price',
        'subtotal'
      ]);
      for (var row in orderDetails) {
        csvData.add([
          row['id_order_detail'],
          row['id_order'],
          row['id_product'],
          row['quantity'],
          row['price'],
          row['subtotal']
        ]);
      }
    }

    // Simpan ke file CSV
    String csvString = const ListToCsvConverter().convert(csvData);
    File file = File(filePath);
    await file.writeAsString(csvString);

    print("File diekspor ke: $filePath");
  }
}
