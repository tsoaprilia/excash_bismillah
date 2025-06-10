import 'dart:developer';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String encryptPassword(String password) {
  // Original key string (ensure this is at least 32 characters)
  String keyString =
      '32charslongkey1234567890123456'; // Make sure this is exactly 32 characters

  // Pad the key if it's less than 32 characters
  keyString = keyString.padRight(32, '0'); // Adds '0' at the end if needed

  // Print key length for debugging
  print('Key Length: ${keyString.length}');

  if (keyString.length != 32) {
    throw ArgumentError('Key length must be exactly 32 characters.');
  }

  final key = encrypt.Key.fromUtf8(keyString); // Create AES key
  final iv = encrypt.IV.fromLength(16); // AES requires 16 bytes IV

  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  // Encrypt the password
  final encrypted = encrypter.encrypt(password, iv: iv);

  // Return the encrypted password in base64 format
  return encrypted.base64;
}

class UserData {
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

    String filePath = '$downloadPath/excash_user.csv';

    // Check if file exists and handle duplication
    File file = File(filePath);
    var count = 1;
    while (file.existsSync()) {
      filePath = '$downloadPath/excash_user ($count).csv';
      file = File(filePath);
      count++;
    }

    List<List<dynamic>> csvData = [];
    Database db = await ExcashDatabase.instance.database;

    // Rest of your export code remains the same
    // Ekspor Tabel User
    List<Map<String, dynamic>> users = await db.query('users');
    if (users.isNotEmpty) {
      csvData.add([
        'id',
        'username',
        'full_name',
        'business_name',
        'business_address',
        'npwp',
        'password',
        'image',
        'phone_number'
      ]);
      for (var row in users) {
        csvData.add([
          row['id'],
          row['username'],
          row['full_name'],
          row['business_name'],
          row['business_address'],
          row['npwp'],
          encryptPassword(row['password']),
          row['image'] ?? '',
          row['phone_number'] ?? '', 
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
