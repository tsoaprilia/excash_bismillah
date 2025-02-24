import 'package:excash/database/excash_database.dart';
import 'package:excash/general_pages/auth/login_page.dart';
import 'package:excash/models/user.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool agreeToTerms = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

 Future<void> registerUser() async {
  if (!agreeToTerms) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Anda harus menyetujui ketentuan sebelum mendaftar."),
      ),
    );
    return;
  }

  String email = emailController.text;
  String fullName = fullNameController.text;
  String businessName = businessNameController.text;
  String password = passwordController.text;
  String confirmPassword = confirmPasswordController.text;

  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password dan konfirmasi password tidak cocok"),
      ),
    );
    return;
  }

  final newUser = User(
    email: email,
    fullName: fullName,
    businessName: businessName,
    password: password,
    image: null, // Jika ada fitur upload foto, bisa diubah nanti
  );

  try {
    await ExcashDatabase.instance.registerUser(newUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi berhasil")),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

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
              buildTextField(
                label: "Email",
                hintText: "aprilia@gmail.com",
                controller: emailController,
              ),
              const SizedBox(height: 16),

              // Input Nama Lengkap
              buildTextField(
                label: "Nama Lengkap",
                hintText: "Aprilia Dwi Cristyana",
                controller: fullNameController,
              ),
              const SizedBox(height: 16),

              // Input Nama Usaha
              buildTextField(
                label: "Nama Usaha",
                hintText: "April'Studio",
                controller: businessNameController,
              ),
              const SizedBox(height: 16),

              // Input Kata Sandi
              buildTextField(
                label: "Kata Sandi",
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Input Konfirmasi Kata Sandi
              buildTextField(
                label: "Konfirmasi Kata Sandi",
                controller: confirmPasswordController,
                obscureText: true,
              ),
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
                               onPressed: registerUser,

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
  Widget buildTextField({
    required String label,
    String? hintText,
    TextEditingController? controller,
    bool obscureText = false,
  }) {
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
          controller: controller,
          obscureText: obscureText,
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
