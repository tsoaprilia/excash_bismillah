import 'package:excash/database/excash_database.dart';
import 'package:excash/general_pages/menu.dart';
import 'package:excash/general_pages/auth/register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  bool isPasswordVisible = false;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRememberedUser();
  }

  Future<void> loadRememberedUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? rememberedFullName = prefs.getString('remembered_full_name');
  String? rememberedPassword = prefs.getString('remembered_password');
  bool? rememberMeState = prefs.getBool('remember_me') ?? false;
  int? rememberMeTimestamp = prefs.getInt('remember_me_timestamp');

  if (rememberMeState == true && rememberedFullName != null && rememberedPassword != null) {
    // Check if the "Remember Me" timestamp is older than 1 week (7 days)
    if (rememberMeTimestamp != null) {
      final timestampDuration = DateTime.now().millisecondsSinceEpoch - rememberMeTimestamp;
      final oneWeekInMilliseconds = 7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds

      if (timestampDuration > oneWeekInMilliseconds) {
        setState(() {
          rememberMe = false; // Expired, reset the flag
        });
        prefs.remove('remembered_full_name');
        prefs.remove('remembered_password');
        prefs.remove('remember_me_timestamp');
      } else {
        // Still within 1 week, load the credentials
        setState(() {
          fullNameController.text = rememberedFullName;
          passwordController.text = rememberedPassword;
          rememberMe = rememberMeState;
        });
      }
    }
  }
}


 
  Future<void> saveUserData(String idUser, String nameLengkap,
    String bisnisName, String bisnisAddress, String? npwp) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id_user', idUser);
  await prefs.setString('name_lengkap', nameLengkap);
  await prefs.setString('bisnis_name', bisnisName);
  await prefs.setString('bisnis_address', bisnisAddress);
  if (npwp != null && npwp.isNotEmpty) {
    await prefs.setString('user_npwp', npwp);
  } else {
    await prefs.remove('user_npwp');
  }

  // Save timestamp when Remember Me was last checked
  if (rememberMe) {
    await prefs.setInt('remember_me_timestamp', DateTime.now().millisecondsSinceEpoch);
  } else {
    await prefs.remove('remember_me_timestamp');
  }
}


 Future<void> loginUser() async {
  String fullName = fullNameController.text; // rename to fullName
  String password = passwordController.text;

  // Update the login query to use fullName and password
  final user = await ExcashDatabase.instance.loginUser(fullName, password);

  if (user != null) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id!);
    await prefs.setString('user_name', user.fullName);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_business_name', user.businessName);
    await prefs.setString('user_business_address', user.businessAddress);
    if (user.npwp != null && user.npwp!.isNotEmpty) {
      await prefs.setString('user_npwp', user.npwp!);
    }

    // Simpan data user untuk transaksi
    await saveUserData(
      user.id!,
      user.fullName,
      user.businessName,
      user.businessAddress,
      user.npwp,
    );

    if (rememberMe) {
      await prefs.setString('remembered_full_name', fullName); // Save fullName
      await prefs.setString('remembered_password', password); // Save password
      await prefs.setBool('remember_me', true); // Save rememberMe state
      await prefs.setInt('remember_me_timestamp', DateTime.now().millisecondsSinceEpoch); // Save timestamp
    } else {
      await prefs.remove('remembered_full_name');
      await prefs.remove('remembered_password');
      await prefs.setBool('remember_me', false); // Save rememberMe state
      await prefs.remove('remember_me_timestamp');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login berhasil")),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Full Name atau password salah")),
    );
  }
}

// Future<void> loginUser() async {
//   String email = fullNameController.text;
//   String password = passwordController.text;

//   final user = await ExcashDatabase.instance.loginUser(email, password);
//   if (user != null) {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('user_id', user.id!);  // Pastikan ID disimpan di sini
//     await prefs.setString('user_name', user.fullName);
//     await prefs.setString('user_email', user.email);
//     await prefs.setString('user_business_name', user.businessName);

//     // Simpan data user untuk transaksi
//     await saveUserData(user.id!, user.fullName, user.businessName);

//     if (rememberMe) {
//       await prefs.setString('remembered_email', email);
//       await prefs.setString('remembered_password', password);
//     } else {
//       await prefs.remove('remembered_email');
//       await prefs.remove('remembered_password');
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Login berhasil")),
//     );
//     Navigator.pushReplacement(
//         context, MaterialPageRoute(builder: (context) => const MainScreen()));
//   } else {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Email atau password salah")),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.1),
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
                    color: Color(0xFF6C727F),
                  ),
                ),
                const SizedBox(height: 24),
                buildTextField("Nama Pengguna", fullNameController,
                    hintText: "Aprilia Dwi Cristyana"),
                const SizedBox(height: 16),
                buildTextField("Kata Sandi", passwordController,
                    obscureText: !isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    )),
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
                      activeColor: const Color(0xFF6C727F),
                    ),
                    const Text(
                      "Ingatkan Saya",
                      style: TextStyle(color: Color(0xFF6C727F)),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        " ",
                        style: TextStyle(
                          color: Color(0xFFD39054),
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
                    onPressed: loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1E1E),
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
                const SizedBox(height: 16),
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
                          color: Color(0xFF6C727F),
                        ),
                        children: [
                          TextSpan(text: "Belum punya akun? "),
                          TextSpan(
                            text: "Buat Sekarang!",
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
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, String? hintText, Widget? suffixIcon}) {
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
