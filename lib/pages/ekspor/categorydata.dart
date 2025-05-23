import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class CategoryData {
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

    String filePath = '$downloadPath/excash_category2.csv';

    // Check if file exists and handle duplication
    File file = File(filePath);
    var count = 1;
    while (file.existsSync()) {
      filePath = '$downloadPath/excash_category2 ($count).csv';
      file = File(filePath);
      count++;
    }

    List<List<dynamic>> csvData = [];
    Database db = await ExcashDatabase.instance.database;

    // Rest of your export code remains the same
    List<Map<String, dynamic>> category = await db.query('category');
    if (category.isNotEmpty) {
      csvData.add([]); // Baris kosong pemisah antar tabel
     csvData.add([
      'id_category',
      'id',
      'name_category',
      'created_at_category',
      'updated_at_category'
    ]);
      for (var row in category) {
        csvData.add([
        row['id_category'],
        row['id'],
        row['name_category'],
        row['created_at_category'],
        row['updated_at_category'] ?? ''
      ]);
      }
    }

    // Remaining export code...

    // Simpan ke file CSV
    String csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    print("File diekspor ke: $filePath");
  }
}
