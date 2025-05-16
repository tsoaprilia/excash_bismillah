import 'package:flutter/material.dart';
import 'package:excash/database/excash_database.dart';
import 'package:telephony/telephony.dart';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final Telephony telephony = Telephony.instance;

  String generatedOTP = "";
  bool otpSent = false;
  bool otpVerified = false;

  void requestPermissions() async {
    await telephony.requestPhoneAndSmsPermissions;
  }

  void sendOTP() async {
    final phone = phoneController.text.trim();
    final user = await ExcashDatabase.instance.getUserByPhone(phone);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Nomor telepon tidak terdaftar")),
      );
      return;
    }

    generatedOTP = (1000 + Random().nextInt(9000)).toString();

    await telephony.sendSms(
      to: phone,
      message: "Kode OTP kamu adalah: $generatedOTP",
    );

    setState(() {
      otpSent = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("OTP telah dikirim ke nomor $phone")),
    );
  }

  void verifyOTP() {
    if (otpController.text.trim() == generatedOTP) {
      setState(() {
        otpVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP benar, silakan masukkan password baru")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP salah")),
      );
    }
  }

  void resetPassword() async {
    final phone = phoneController.text.trim();
    final newPassword = newPasswordController.text.trim();

    final user = await ExcashDatabase.instance.getUserByPhone(phone);
    if (user != null) {
      final updatedUser = user.copy(password: newPassword);
      await ExcashDatabase.instance.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password berhasil diubah. Silakan login.")),
      );

      Navigator.pop(context); // Kembali ke halaman login
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget buildButton({required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD39054),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(label, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 24, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Lupa Kata Kunci",
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Image.asset(
                  'assets/img/lupa_sandi.png',
                  height: 130,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(height: 20),
              buildTextField(
                controller: phoneController,
                hint: "Nomor Telepon",
                inputType: TextInputType.phone,
              ),
              if (!otpSent) buildButton(label: "Kirim OTP", onPressed: sendOTP),
              if (otpSent && !otpVerified) ...[
                buildTextField(
                  controller: otpController,
                  hint: "Masukkan OTP",
                  inputType: TextInputType.number,
                ),
                buildButton(label: "Verifikasi OTP", onPressed: verifyOTP),
              ],
              if (otpVerified) ...[
                buildTextField(
                  controller: newPasswordController,
                  hint: "Password Baru",
                  isPassword: true,
                ),
                buildButton(label: "Reset Password", onPressed: resetPassword),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
