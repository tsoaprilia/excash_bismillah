import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ExportData {
  Future<void> exportToCSV() async {
    // Pastikan izin penyimpanan diberikan
    if (await Permission.manageExternalStorage.request().isDenied) {
      print("Izin penyimpanan ditolak!");
      return;
    }

    // Dapatkan path penyimpanan (misalnya directory eksternal)
    String? downloadPath = await getDownloadPath();
    if (downloadPath == null) {
      print("Gagal mendapatkan path penyimpanan.");
      return;
    }

    String filePath = '$downloadPath/excash_category_BISMILLAH.csv';

    // Cek jika file sudah ada, kemudian buat nama file unik
    File file = File(filePath);
    var count = 1;
    while (file.existsSync()) {
      filePath = '$downloadPath/excash_category_BISMILLAH ($count).csv';
      file = File(filePath);
      count++;
    }

    List<List<dynamic>> csvData = [];
    Database db = await ExcashDatabase.instance.database;

    // Tambahkan indicator row untuk nama tabel (sesuai nama tabel di database)
    csvData.add(['category']);

    // Tambahkan header row
    csvData.add([
      'id_category',
      'id',
      'name_category',
      'created_at_category',
      'updated_at_category'
    ]);

    // Ekspor data kategori
    List<Map<String, dynamic>> categories = await db.query('category');
    for (var row in categories) {
      csvData.add([
        row['id_category'],
        row['id'],
        row['name_category'],
        row['created_at_category'],
        row['updated_at_category'] ?? ''
      ]);
    }

    // Ubah list menjadi string CSV
    String csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString);
    print("File diekspor ke: $filePath");
  }

  Future<String?> getDownloadPath() async {
    Directory? directory = await getExternalStorageDirectory();
    return directory?.path;
  }
}
