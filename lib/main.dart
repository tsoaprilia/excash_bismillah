import 'dart:io';
import 'package:excash/filemanager.dart';
import 'package:excash/general_pages/auth/auth_page.dart';
import 'package:excash/general_pages/onboarding_screen.dart';
import 'package:excash/general_pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Function to request storage permissions
Future<void> requestStoragePermission() async {
  if (await Permission.manageExternalStorage.request().isGranted) {
    print("✅ Izin penyimpanan diberikan!");
  } else {
    print("❌ Izin penyimpanan ditolak!");
    await openAppSettings();
  }
}

// Function to get download path
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

// Function to save file to external storage
Future<void> saveFileToDownload() async {
  final downloadDir = await getDownloadPath();
  if (downloadDir != null) {
    const fileName = "excash_export.csv";
    var savePath = "$downloadDir/$fileName";
    File file = File(savePath);

    // Check if file exists, add suffix to avoid overwriting
    var count = 1;
    while (file.existsSync()) {
      savePath = "$downloadDir/excash_export ($count).csv";
      file = File(savePath);
      count++;
    }

    try {
      final directory = Directory(downloadDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      await file.writeAsString("Data CSV berhasil disimpan!");
      print("✅ File disimpan di: $savePath");
    } catch (e) {
      print("❌ Error saving file: $e");
    }
  } else {
    print("❌ Gagal mendapatkan path penyimpanan.");
  }
}

// di main.dart tambahkan:
Future<bool> isFirstTimeUser() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('tutorial_completed') ?? false;
}

Future<void> setTutorialCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('tutorial_completed', true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestStoragePermission();

  FileManager fileManager = FileManager();
  String? externalPath = await fileManager.getExternalStoragePath();

  if (externalPath != null) {
    print("Path penyimpanan eksternal: $externalPath");
  } else {
    print("Gagal mendapatkan path penyimpanan eksternal.");
  }

  // Cek apakah onboarding sudah selesai
  final prefs = await SharedPreferences.getInstance();
  bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(
    ShowCaseWidget(
      builder: (context) => MyApp(showOnboarding: !onboardingComplete),
    ),
  );
}


class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: showOnboarding ? const OnboardingScreen() : const SplashScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFD39054)),
        useMaterial3: true,
      ),
    );
  }
}
