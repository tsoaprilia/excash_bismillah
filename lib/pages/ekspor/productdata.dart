import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ProductData {
  Future<void> exportToCSV() async {
    // Pastikan izin penyimpanan diberikan
    if (await Permission.manageExternalStorage.request().isDenied) {
      print("Izin penyimpanan ditolak!");
      return;
    }

    // Get download path instead of app documents directory
    String? downloadPath = await getDownloadPath();
    if (downloadPath == null) {
      print("Gagal mendapatkan path penyimpanan.");
      return;
    }

    String filePath = '$downloadPath/excash_product.csv';

    // Check if file exists and handle duplication
    File file = File(filePath);
    var count = 1;
    while (file.existsSync()) {
      filePath = '$downloadPath/excash_product ($count).csv';
      file = File(filePath);
      count++;
    }

    List<List<dynamic>> csvData = [];
    Database db = await ExcashDatabase.instance.database;

    // Rest of your export code remains the same
    // Ekspor Tabel Product
    List<Map<String, dynamic>> products = await db.query('product');
    if (products.isNotEmpty) {
      csvData.add([]); // Baris kosong pemisah antar tabel
      csvData.add([
        'id_product',
        'id',
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
          row['id'],
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

    // Simpan ke file CSV
    String csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    print("File diekspor ke: $filePath");
  }
}
