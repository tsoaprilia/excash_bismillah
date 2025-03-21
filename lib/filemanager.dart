import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileManager {
  // Fungsi untuk mendapatkan path penyimpanan eksternal
  Future<String?> getExternalStoragePath() async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      print("Directory tidak ditemukan");
      return null;
    }

    print("Direktori ditemukan: ${directory.path}");
    return directory.path;
  }
}
