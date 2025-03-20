import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';

class ImportData {
  Future<void> importFromCSV() async {
    Database db = await ExcashDatabase.instance.database;

    // Pilih file CSV
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null) {
      print("Pemilihan file dibatalkan.");
      return;
    }

    File file = File(result.files.single.path!);
    String fileContent = await file.readAsString();
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(fileContent);

    if (csvTable.isEmpty) {
      print("File CSV kosong!");
      return;
    }

    String? currentTable;
    List<String>? columns;

    for (var row in csvTable) {
      if (row.isEmpty) continue;

      // Jika ada header baru, set tabel target
      if (row.first is String && row.length > 1) {
        currentTable = row.first;
        columns = row.sublist(1).cast<String>();
      } else if (currentTable != null && columns != null) {
        Map<String, dynamic> data = {};
        for (int i = 0; i < columns.length; i++) {
          data[columns[i]] = row[i];
        }

        await db.insert(currentTable, data,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    print("Data berhasil diimpor dari CSV!");
  }
}
