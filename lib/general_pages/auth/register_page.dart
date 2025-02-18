import 'package:excash/general_pages/auth/login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
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
                "Lakukan pendaftaran akun",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6C727F), // Warna abu-abu
                ),
              ),
              const SizedBox(height: 24),

              // Input Email
              buildTextField(label: "Email", hintText: "aprilia@gmail.com"),
              const SizedBox(height: 16),

              // Input Nama Lengkap
              buildTextField(
                  label: "Nama Lengkap", hintText: "Aprilia Dwi Cristyana"),
              const SizedBox(height: 16),

              // Input Nama Usaha
              buildTextField(label: "Nama Usaha", hintText: "April'Studio"),
              const SizedBox(height: 16),

              // Input Kata Sandi
              buildTextField(label: "Kata Sandi", isPassword: true),
              const SizedBox(height: 16),

              // Input Konfirmasi Kata Sandi
              buildTextField(label: "Konfirmasi Kata Sandi", isPassword: true),
              const SizedBox(height: 16),

              // Checkbox Setuju Syarat dan Ketentuan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agreeToTerms,
                    onChanged: (bool? newValue) {
                      setState(() {
                        agreeToTerms = newValue!;
                      });
                    },
                    activeColor: const Color(0xFF6C727F), // Warna abu-abu
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                            color: Color(0xFF6C727F)), // Warna abu-abu
                        children: [
                          TextSpan(text: "Saya setuju dengan Excash "),
                          TextSpan(
                            text: "ketentuan penggunaan",
                            style: TextStyle(
                              color: Color(0xFFD39054), // Warna orange
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: "\ndan telah membacanya"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
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
                    "Daftar",
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
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6C727F), // Warna abu-abu
                      ),
                      children: [
                        TextSpan(text: "SudahBelum punya akun? "),
                        TextSpan(
                          text: "Login Sekarang!",
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
              const SizedBox(height: 24), // Tambahkan padding bawah
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat text field
  Widget buildTextField(
      {required String label, String? hintText, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12),
            ),
          ),
        ),
      ],
    );
  }
}
