import 'dart:io';
import 'package:excash/filemanager.dart';
import 'package:excash/general_pages/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Fungsi untuk meminta izin penyimpanan
Future<void> requestStoragePermission() async {
  // Meminta izin akses penyimpanan eksternal untuk Android 10+
  if (await Permission.manageExternalStorage.request().isGranted) {
    print("✅ Izin penyimpanan diberikan!");
  } else {
    print("❌ Izin penyimpanan ditolak!");
    await openAppSettings(); // Membuka pengaturan jika izin ditolak
  }
}

Future<String?> getDownloadPath() async {
  Directory? directory;
  try {
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    }
  } catch (err) {
    print("Tidak dapat mengambil path folder download");
  }
  return directory?.path;
}

// Fungsi untuk menyimpan file CSV ke penyimpanan eksternal
Future<void> saveFileToDownload() async {
  final downloadDir = await getDownloadPath();
  if (downloadDir != null) {
    const fileName = "excash_export.csv";
    var savePath = "$downloadDir/$fileName";

    File file = File(savePath);

    // Jika file sudah ada, tambahkan angka di belakang nama file
    var count = 1;
    while (file.existsSync()) {
      savePath = "$downloadDir/excash_export ($count).csv";
      file = File(savePath);
      count++;
    }

    // Simpan file CSV di path yang sudah dipastikan
    await file.writeAsString("Data CSV berhasil disimpan!");
    print("✅ File disimpan di: $savePath");
  } else {
    print("❌ Gagal mendapatkan path penyimpanan.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FileManager fileManager = FileManager();

  // Memanggil fungsi untuk mendapatkan path penyimpanan eksternal
  String? externalPath = await fileManager.getExternalStoragePath();

  if (externalPath != null) {
    print("Path penyimpanan eksternal: $externalPath");
  } else {
    print("Gagal mendapatkan path penyimpanan eksternal.");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthPage(),
    );
  }
}
