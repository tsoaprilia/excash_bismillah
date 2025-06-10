import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class OrderDetailData {
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

    String filePath = '$downloadPath/excash_orderdetail.csv';

    // Check if file exists and handle duplication
    File file = File(filePath);
    var count = 1;
    while (file.existsSync()) {
      filePath = '$downloadPath/excash_orderdetail ($count).csv';
      file = File(filePath);
      count++;
    }

    List<List<dynamic>> csvData = [];
    Database db = await ExcashDatabase.instance.database;

    // Rest of your export code remains the same
       // Ekspor Tabel Order Detail
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
    await file.writeAsString(csvString);
    print("File diekspor ke: $filePath");
  }
}
