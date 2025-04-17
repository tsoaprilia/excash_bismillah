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
    Database db = await ExcashDatabase.instance.database;
    String fileContent = await file.readAsString();
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(fileContent);

    if (csvTable.isEmpty) {
      print("File CSV kosong!");
      return;
    }

    String? currentTable = type;
    List<String>? columns;

    for (var row in csvTable) {
      if (row.isEmpty) continue;

      // Mengambil nama kolom dari baris pertama CSV
      if (row.first is String && row.length > 1) {
        columns = row.sublist(1).cast<String>(); // Ambil nama kolom
      } else if (columns != null) {
        Map<String, dynamic> data = {};
        for (int i = 0; i < columns.length; i++) {
          data[columns[i]] = row[i] ?? '';
        }

        if (currentTable == 'users') {
          // Gantilah 'user' menjadi 'users' dan gunakan INSERT OR IGNORE agar data tidak diganti jika sudah ada email yang sama
          data[UserFields.id] =
              row[0] ?? Uuid().v4(); // Generate UUID jika tidak ada
          data[UserFields.email] = row[1];
          data[UserFields.fullName] = row[2];
          data[UserFields.businessName] = row[3];
          data[UserFields.password] = row[4];
          data[UserFields.image] = row[5] ?? 'N/A';

          print('Inserting user: $data'); // Debugging log
          await db.insert(currentTable!, data,
              conflictAlgorithm: ConflictAlgorithm
                  .ignore); // Menggunakan ignore agar tidak mengganti data yang sudah ada
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
    }

    print("Data berhasil diimpor dari CSV!");
  }
}
