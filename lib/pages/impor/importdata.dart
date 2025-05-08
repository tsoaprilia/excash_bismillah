import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/user.dart';
import 'package:excash/models/product.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

class ImportData {
  Future<void> importFromCSV(File file, String type) async {
    print("start of import csv $type ${file.path}");
    Database db = await ExcashDatabase.instance.database;
    String fileContent = await file.readAsString();
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(fileContent);
    print("Check CSV Table: ${csvTable.length}");

    if (csvTable.isEmpty) {
      print("File CSV kosong!");
      return;
    }

    String? currentTable = type;
    List<String>? columns;

    for (var i = 0; i < csvTable.length; i++) {
      var row = csvTable[i];
      if (row.isEmpty) continue;

      if (i == 0) {
        columns = row.sublist(1).cast<String>(); // Ambil nama kolom
        print('CSV Headers: $columns');
      } else {
        Map<String, dynamic> data = {};
        for (int j = 0; j < columns!.length; j++) {
          data[columns[j]] = row[j];
        }

        print('Inserting $currentTable: $data');

        if (currentTable == 'users') {
          if (row.length >= 6) {
            data[UserFields.id] = row[0]; // Generate UUID jika tidak ada
            data[UserFields.username] = row[1];
            data[UserFields.fullName] = row[2];
            data[UserFields.businessName] = row[3];
            data[UserFields.businessAddress] = row[4];
            data[UserFields.npwp] = row[5];
            data[UserFields.password] = row[6];
            data[UserFields.image] = row[7] ?? 'N/A';

            // Menambahkan data ke tabel 'users', jika email sudah ada, maka data baru akan diabaikan
            print('Inserting user data: $data'); // Debugging log
            await db.insert(currentTable!, data,
                conflictAlgorithm: ConflictAlgorithm
                    .replace); // Ini akan menggantikan data lama jika email sudah ada
          }
        }

        // Untuk Category
        if (currentTable == 'category') {
          if (row.length >= 5) {
            data[CategoryFields.id_category] = row[0];
            data[CategoryFields.id] = row[1];
            data[CategoryFields.name_category] = row[2];
            data[CategoryFields.created_at_category] = row[3];
            data[CategoryFields.updated_at_category] = row[4];
            print('Inserting category: $data'); // Debugging log
            await db.insert(currentTable!, data,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        // Untuk Product
        if (currentTable == 'product') {
          if (row.length >= 10) {
            data[ProductFields.id_product] = row[0];
            data[ProductFields.id] = row[1];
            data[ProductFields.id_category] = row[2];
            data[ProductFields.name_product] = row[3];
            data[ProductFields.price] = row[4];
            data[ProductFields.selling_price] = row[5];
            data[ProductFields.stock] = row[6];
            data[ProductFields.description] = row[7];
            data[ProductFields.created_at] = row[8];
            data[ProductFields.updated_at] = row[9];
            data[ProductFields.is_disabled] = row[10];

            print('Inserting product: $data'); // Debugging log
            await db.insert(currentTable!, data,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        // Untuk Orders
        if (currentTable == 'orders') {
          if (row.length >= 7) {
            data[OrderFields.id_order] = row[0];
            data[OrderFields.id] = row[1];
            data[OrderFields.total_product] = row[2];
            data[OrderFields.total_price] = row[3];
            data[OrderFields.payment] = row[4];
            data[OrderFields.change] = row[5];
            data[OrderFields.created_at] = row[6];
            print('Inserting order: $data'); // Debugging log
            await db.insert(currentTable!, data,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        // Untuk Order Detail
        if (currentTable == 'order_detail') {
          if (row.length >= 6) {
            data[OrderDetailFields.id_order_detail] = row[0];
            data[OrderDetailFields.id_order] = row[1];
            data[OrderDetailFields.id_product] = row[2];
            data[OrderDetailFields.quantity] = row[3];
            data[OrderDetailFields.price] = row[4];
            data[OrderDetailFields.subtotal] = row[5];
            print('Inserting order detail: $data'); // Debugging log
            await db.insert(currentTable!, data,
                conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      }
      i++;
    }

    print("Data berhasil diimpor dari CSV!");
  }
}
