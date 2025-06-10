import 'package:excash/database/excash_database.dart';
import 'package:excash/general_pages/auth/forgotpassword_page.dart';
import 'package:excash/general_pages/menu.dart';
import 'package:excash/general_pages/auth/register_page.dart';
import 'package:excash/models/user.dart';
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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadRememberedUser();
  }

  Future<void> loadRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rememberedUsername = prefs.getString('remembered_username');
    String? rememberedPassword = prefs.getString('remembered_password');
    bool? rememberMeState = prefs.getBool('remember_me') ?? false;
    int? rememberMeTimestamp = prefs.getInt('remember_me_timestamp');

    if (rememberMeState == true &&
        rememberedUsername != null &&
        rememberedPassword != null) {
      // Check if the "Remember Me" timestamp is older than 1 week (7 days)
      if (rememberMeTimestamp != null) {
        final timestampDuration =
            DateTime.now().millisecondsSinceEpoch - rememberMeTimestamp;
        final oneWeekInMilliseconds =
            7 * 24 * 60 * 60 * 1000; // 1 week in milliseconds

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
            usernameController.text = rememberedUsername;
            passwordController.text = rememberedPassword;
            rememberMe = rememberMeState;
          });
        }
      }
    }
  }

  Future<void> saveUserData(String idUser, String username, String fullName,
      String bisnisName, String bisnisAddress, String? npwp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_user', idUser);
    await prefs.setString('username', username);
    await prefs.setString('nama_lengkap', fullName);
    await prefs.setString('bisnis_name', bisnisName);
    await prefs.setString('bisnis_address', bisnisAddress);
    if (npwp != null && npwp.isNotEmpty) {
      await prefs.setString('user_npwp', npwp);
    } else {
      await prefs.remove('user_npwp');
    }

    // Save timestamp when Remember Me was last checked
    if (rememberMe) {
      await prefs.setInt(
          'remember_me_timestamp', DateTime.now().millisecondsSinceEpoch);
    } else {
      await prefs.remove('remember_me_timestamp');
    }
  }

  Future<User?> _resetPassword(String username) async {
    final db = await ExcashDatabase.instance.database;

    final result = await db.query(
      tableUser,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return User.fromJson(result.first);
    } else {
      return null;
    }
  }

  Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('tutorial_completed') ?? true;
  }

  Future<void> setTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
  }

  Future<void> loginUser({
    required Function(String message) onError,
    required Function(bool firstTime) onSuccess,
  }) async {
    String username = usernameController.text;
    String password = passwordController.text;

    final user = await ExcashDatabase.instance.loginUser(username, password);

    if (user != null) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id!);
      await prefs.setString('user_name', user.fullName);
      await prefs.setString('user_username', user.username);
      await prefs.setString('user_business_name', user.businessName);
      await prefs.setString('user_business_address', user.businessAddress);
      if (user.npwp != null && user.npwp!.isNotEmpty) {
        await prefs.setString('user_npwp', user.npwp!);
      }

      await saveUserData(
        user.id!,
        user.fullName,
        user.username,
        user.businessName,
        user.businessAddress,
        user.npwp,
      );

      if (rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('remembered_username', username);
        await prefs.setString('remembered_password', password);
        await prefs.setInt(
            'remember_me_timestamp', DateTime.now().millisecondsSinceEpoch);
      } else {
        await prefs.setBool('remember_me', false);
        await prefs.remove('remembered_username');
        await prefs.remove('remembered_password');
        await prefs.remove('remember_me_timestamp');
      }

      bool firstTime = await isFirstTimeUser();
      onSuccess(firstTime);
    } else {
      onError("Nama Pengguna atau password salah");
    }
  }

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
                buildTextField("Nama Pengguna", usernameController,
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        "Lupa Kata Sandi",
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
                    onPressed: () {
                      loginUser(
                        onSuccess: (bool firstTime) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Login berhasil")),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => firstTime
                                  ? MainScreen(initialIndex: 1)
                                  : const MainScreen(),
                            ),
                          );
                        },
                        onError: (String error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          );
                        },
                      );
                    },
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

  void _showResetPasswordDialog() {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF424242),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Lupa Kata Sandi",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF424242),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Masukkan nama pengguna untuk reset kata sandi!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6C727F),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'Cth : Aprilia123@',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45, // opsional, bisa disesuaikan
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Nama Pengguna',
                    labelStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      String username = usernameController.text;
                      if (username.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Username tidak boleh kosong"),
                          ),
                        );
                        return;
                      }

                      final user = await _resetPassword(username);
                      if (user != null) {
                        Navigator.pop(context);
                        _showNewPasswordDialog(user);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Pengguna tidak ditemukan"),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color.fromARGB(255, 0, 0, 0), // Warna background
                      foregroundColor: Colors.white, // Warna teks
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Cek Nama",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNewPasswordDialog(User user) {
    final TextEditingController newPasswordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          color: Color(0xFF424242),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            "Atur Kata Sandi Baru",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF424242),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Masukkan kata sandi baru untuk akun anda!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6C727F),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: newPasswordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Cth : User123@',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black45, // opsional, bisa disesuaikan
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Kata Sandi Baru',
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
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
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          String newPassword = newPasswordController.text;
                          if (newPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Kata sandi tidak boleh kosong"),
                              ),
                            );
                            return;
                          }

                          // Update kata sandi di database
                          final db = await ExcashDatabase.instance.database;
                          await db.update(
                            tableUser,
                            {UserFields.password: newPassword},
                            where: '${UserFields.id} = ?',
                            whereArgs: [user.id],
                          );

                          Navigator.pop(context); // Tutup dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Kata sandi berhasil diubah")),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Color.fromARGB(255, 0, 0, 0), // Warna background
                          foregroundColor: Colors.white, // Warna teks
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Ubah Kata Sandi",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
