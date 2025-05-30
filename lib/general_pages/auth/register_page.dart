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

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Fungsi untuk validasi format password
  bool isValidPassword(String password) {
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegExp.hasMatch(password);
  }

  // Fungsi untuk validasi format username
  bool isValidUsername(String username) {
    final RegExp usernameRegExp = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$',
    );
    return usernameRegExp.hasMatch(username);
  }

  bool isValidPhoneNumber(String phone) {
    final RegExp phoneRegExp = RegExp(r'^(0|\+62)\d{9,12}$');
    return phoneRegExp.hasMatch(phone);
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

    String username = usernameController.text;
    String fullName = fullNameController.text;
    String businessName = businessNameController.text;
    String businessAddress = businessAddressController.text;
    String npwp = npwpController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phoneNumber = phoneNumberController.text;

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor telepon tidak boleh kosong")),
      );
      return;
    }

    if (!isValidPhoneNumber(phoneNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Nomor telepon tidak valid. Gunakan 10-13 digit, mulai dengan 0 atau +62")),
      );
      return;
    }

    if (businessAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alamat usaha tidak boleh kosong")),
      );
      return;
    }

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
    if (!isValidUsername(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Username harus mengandung huruf besar, huruf kecil, angka, dan simbol."),
        ),
      );
      return;
    }

    final newUser = User(
      username: username,
      fullName: fullName,
      businessName: businessName,
      businessAddress: businessAddress,
      npwp: npwp.isEmpty ? null : npwp,
      password: password,
      image: null,
      phoneNumber: phoneNumber,
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
                label: "Nama Pengguna",
                hintText: "Aprilia123@",
                controller: usernameController,
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
                label: "Alamat Usaha",
                hintText: "Jl. Mawar No. 12, Surabaya",
                controller: businessAddressController,
              ),
              const SizedBox(height: 16),
              buildTextField(
                label: "NPWP (Opsional)",
                hintText: "1234567890",
                controller: npwpController,
              ),
              buildTextField(
                label: "Nomor Telepon ",
                hintText: "1234567890",
                controller: phoneNumberController,
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
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black)),
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
                borderSide: const BorderSide(color: Colors.black12)),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
