import 'package:excash/pages/dashboard/dashboard_page.blade.dart';
import 'package:excash/pages/ekspor/ekspor_page.blade.dart';
import 'package:excash/pages/impor/impor_page.blade.dart';
import 'package:excash/pages/log/log_page.blade.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/img/profile.png', // Ganti dengan path gambar yang sesuai
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Nama Pengguna
                  const Text(
                    "Aprilia Dwi Cristyana",
                    style: TextStyle(
                      fontSize: 14, // Ukuran font 14px
                      fontWeight: FontWeight.w600, // Semi-bold
                      color: Color(0xFF414040), // Warna teks
                    ),
                  ),

                  const SizedBox(height: 8),
                  // Tombol Edit Profil
                  ElevatedButton.icon(
                    onPressed: () {
                      // Tambahkan fungsi edit profil
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
                        _buildInfoRow("Email", "aprilia@gmail.com"),
                        _buildInfoRow("Nama Usaha", "April’s Studio"),
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
                    Icons.exit_to_app,
                    "Keluar",
                    () {
                      // Tambahkan aksi logout
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
