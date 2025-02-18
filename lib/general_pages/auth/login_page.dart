import 'package:excash/general_pages/menu.dart';
import 'package:excash/general_pages/auth/register_page.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/img/excash_logo_hitam.png',
                height: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Selamat Datang!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Silahkan masuk untuk menikmati fiturnya",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C727F), // Warna abu-abu
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "aprilia@gmail.com",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Kata Sandi",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (bool? newValue) {
                    setState(() {
                      rememberMe = newValue!;
                    });
                  },
                  activeColor: const Color(0xFF6C727F), // Warna abu-abu
                ),
                const Text(
                  "Ingatkan Saya",
                  style: TextStyle(color: Color(0xFF6C727F)), // Warna abu-abu
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    // Tambahkan aksi lupa password
                  },
                  child: const Text(
                    "Lupa Kata Kunci?",
                    style: TextStyle(
                      color: Color(0xFFD39054), // Warna orange
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E), // Warna hitam
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Masuk",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16), // Tambahkan jarak sebelum teks daftar

            // Teks "Belum punya akun? Buat Sekarang!"
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6C727F), // Warna abu-abu
                    ),
                    children: [
                      TextSpan(text: "Belum punya akun? "),
                      TextSpan(
                        text: "Buat Sekarang!",
                        style: TextStyle(
                          color: Color(0xFFD39054), // Warna orange
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
