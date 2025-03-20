import 'dart:io';
import 'package:excash/general_pages/auth/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

// Fungsi untuk mendapatkan path file CSV di perangkat
Future<String> getCsvPath() async {
  Directory? directory;

  // Cek platform Android
  if (Platform.isAndroid) {
    directory =
        await getExternalStorageDirectory(); // Mengambil direktori eksternal
    if (directory == null) {
      directory = Directory(
          "/storage/emulated/0/Documents"); // Fallback jika tidak ditemukan
    }
  } else {
    directory =
        await getApplicationDocumentsDirectory(); // Direktori untuk platform selain Android
  }

  return "${directory.path}/data.csv"; // Menyimpan file dengan nama data.csv
}

// Fungsi untuk meminta izin penyimpanan
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print("✅ Izin akses diberikan!");
      return true;
    } else {
      print("❌ Izin akses ditolak!");
      await openAppSettings(); // Buka pengaturan jika izin ditolak
      return false;
    }
  }
  return true; // Tidak perlu izin untuk platform lain seperti iOS
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // WAJIB DIPANGGIL DULU

  bool permissionGranted = await requestStoragePermission();
  if (permissionGranted) {
    String filePath = await getCsvPath();
    File file = File(filePath);
    await file.writeAsString("Data CSV berhasil disimpan!");
    print("✅ File disimpan di: $filePath");
  } else {
    print("❌ Gagal menyimpan file karena izin ditolak.");
  }
  await openAppSettings();
  runApp(const MyApp());
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
