import 'dart:io';

import 'package:excash/general_pages/auth/login_page.dart';
import 'package:excash/pages/dashboard/dashboard_page.blade.dart';
import 'package:excash/pages/ekspor/ekspor_page.blade.dart';
import 'package:excash/pages/impor/impor_page.blade.dart';
import 'package:excash/pages/log/log_page.blade.dart';
import 'package:excash/pages/profile/edit_profile_page.dart';
import 'package:excash/pages/transaction/print.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = "Nama Pengguna";
  String _userUsername = "Full Pengguna";
  String _userbusinessName = "Nama Bisnis";
  String _profileImage = 'assets/img/profile.jpg';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _saveProfileImage(String pickedFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_image', pickedFile);
  }

// Fungsi untuk mengambil data user dari SharedPreferences

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Nama Lengkap";
      _userUsername = prefs.getString('user_username') ?? "Nama Pengguna";
      _userbusinessName =
          prefs.getString('user_business_name') ?? "Nama Bisnis";
      _profileImage =
          prefs.getString('user_profile_image') ?? 'assets/img/profile.jpg';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bagian Header
            Container(
              height: 140,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -50),
              child: Column(
                children: [
                  // Foto Profil
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          4), // Border radius untuk gambar
                      child: _profileImage.startsWith('assets')
                          ? Image.asset(_profileImage, fit: BoxFit.cover)
                          : Image.file(File(_profileImage), fit: BoxFit.cover),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Nama Pengguna
                  Text(
                    _userUsername,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF414040),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Tombol Edit Profil
                  ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditProfilePage()),
                      );
                      setState(() {
                        _loadUserData();
                      }); // Paksa update tampilan setelah kembali
                    },
                    icon: const Icon(Icons.edit, size: 12),
                    label: const Text("Edit Profil"),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Informasi Email dan Nama Usaha
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildInfoRow("Nama Lengkap", _userName),
                        _buildInfoRow("Nama Usaha", _userbusinessName),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Container(
                      width: double.infinity,
                      height: 1, // Ketebalan 2px
                      color: Color(0xFF414040), // Warna #414040
                    ),
                  ),
                  // List Menu
                  _buildMenuItem(
                    Icons.dashboard,
                    "Dashboard Reporting",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DashboardPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.list,
                    "Log Aktivitas",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LogPage()),
                      );
                    },
                  ),
                  // _buildMenuItem(
                  //   Icons.file_download,
                  //   "Ekspor Import Data",
                  //   () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => ExportImportPage()),
                  //     );
                  //   },
                  // ),
                  _buildMenuItem(
                    Icons.file_download,
                    "Ekspor Data",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExportPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.file_upload,
                    "Impor Data",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ImporPage()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    Icons.print,
                    "Print",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrintSettingsPage()),
                      );
                    },
                  ),

                  _buildMenuItem(
                    Icons.exit_to_app,
                    "Keluar",
                    () async {
                      bool confirmLogout = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.white, // Ensure it's white
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Ensure it's white
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Icon(
                                        Icons.event_note_outlined,
                                        color: const Color(
                                            0xFF424242), // Text color
                                        size: 24,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Konfirmasi Logout",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Color(0xFF424242),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Close button with shadow
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.05),
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 18),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Image (status or any other image you want to add)
                                  Image.asset(
                                    'assets/img/confirm.png', // Replace with your image path
                                    width: 60,
                                    height: 60,
                                  ),
                                  const SizedBox(height: 16),

                                  // Message
                                  Text(
                                    "Apakah Anda yakin ingin logout?",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color:
                                          Color(0xFF757B7B), // Soft text color
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true); // Not logout
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            primary: Colors
                                                .white, // Background color of the button
                                            onPrimary:
                                                Color(0xFF424242), // Text color
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal:
                                                    24), // Adjust padding
                                            side: BorderSide(
                                                color: Color(
                                                    0xFF424242)), // Border color
                                          ),
                                          child: const Text(
                                            "Ya",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width:
                                              8), // Optional: Add space between the buttons
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                false); // Proceed with logout
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            primary: Colors
                                                .white, // Background color of the button
                                            onPrimary:
                                                Color(0xFFD39054), // Text color
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12,
                                                horizontal:
                                                    24), // Adjust padding
                                            side: BorderSide(
                                                color: Color(
                                                    0xFFD39054)), // Border color
                                          ),
                                          child: const Text(
                                            "Tidak",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );

                      if (confirmLogout == true) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.remove('user_id');
                        await prefs.remove('user_name');
                        await prefs.remove('user_email');
                        await prefs.remove('user_business_name');

                        if (mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan informasi email dan nama usaha
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF757B7B), // Warna #757B7B
              fontSize: 12, // Ukuran font 12px
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF757B7B),
              fontSize: 14, // Tetap 14px untuk nilai
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan item menu dengan shadow dan border radius
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(title, style: const TextStyle(fontSize: 16)),
          onTap: onTap, // Panggil fungsi yang diberikan
        ),
      ),
    );
  }
}
