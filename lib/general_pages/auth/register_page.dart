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
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Fungsi untuk validasi format password
  bool isValidPassword(String password) {
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

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

    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Password harus minimal 8 karakter, mengandung huruf besar, angka, dan simbol."),
        ),
      );
      return;
    }

    final newUser = User(
      email: email,
      fullName: fullName,
      businessName: businessName,
      password: password,
      image: null,
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
      backgroundColor: Colors.white, 
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
                  color: Color(0xFF6C727F),
                ),
              ),
              const SizedBox(height: 24),

              buildTextField(
                label: "Email",
                hintText: "aprilia@gmail.com",
                controller: emailController,
              ),
              const SizedBox(height: 16),

              buildTextField(
                label: "Nama Lengkap",
                hintText: "Aprilia Dwi Cristyana",
                controller: fullNameController,
              ),
              const SizedBox(height: 16),

              buildTextField(
                label: "Nama Usaha",
                hintText: "April'Studio",
                controller: businessNameController,
              ),
              const SizedBox(height: 16),

              buildTextField(
                label: "Kata Sandi",
                controller: passwordController,
                obscureText: !isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              buildTextField(
                label: "Konfirmasi Kata Sandi",
                controller: confirmPasswordController,
                obscureText: !isConfirmPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

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
                    activeColor: const Color(0xFF6C727F),
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Color(0xFF6C727F)),
                        children: [
                          TextSpan(text: "Saya setuju dengan Excash "),
                          TextSpan(
                            text: "ketentuan penggunaan",
                            style: TextStyle(
                              color: Color(0xFFD39054),
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

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
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
              const SizedBox(height: 16),
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
                      style: TextStyle(fontSize: 14, color: Color(0xFF6C727F)),
                      children: [
                        TextSpan(text: "Sudah punya akun? "),
                        TextSpan(
                          text: "Login Sekarang!",
                          style: TextStyle(
                            color: Color(0xFFD39054),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    String? hintText,
    TextEditingController? controller,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black12)),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
