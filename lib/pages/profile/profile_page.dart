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
  String _userEmail = "Email Pengguna";
  String _userbusinessName = "Nama Bisnis";
  String _profileImage = 'assets/img/profile.png';

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
      _userName = prefs.getString('user_name') ?? "Nama Pengguna";
      _userEmail = prefs.getString('user_email') ?? "Email Pengguna";
      _userbusinessName =
          prefs.getString('user_business_name') ?? "Nama Bisnis";
      _profileImage =
          prefs.getString('user_profile_image') ?? 'assets/img/profile.png';
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
                    _userName,
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
                        _buildInfoRow("Email", _userEmail),
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
                  _buildMenuItem(
                    Icons.file_download,
                    "Ekspor Data",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const eksporPage()),
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
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dialogBackgroundColor:
                                  Colors.white, // Pastikan background putih
                            ),
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // Radius 10
                              ),
                              title: const Text(
                                "Konfirmasi Logout",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color(0xFF424242),
                                ),
                              ),
                              content: const Text(
                                "Apakah Anda yakin ingin logout?",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Color(
                                      0xFF757B7B), // Warna teks lebih soft
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // Tidak logout
                                  },
                                  child: const Text(
                                    "Ya",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFF424242),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // Ya, lanjut logout
                                  },
                                  child: const Text(
                                    "Tidak",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Color(0xFFD39054),
                                    ),
                                  ),
                                ),
                              ],
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
