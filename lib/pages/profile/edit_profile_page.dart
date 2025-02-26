import 'package:excash/database/excash_database.dart';
import 'package:excash/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  File? _image;
  int? userId;
  String? password; // Simpan password agar tidak hilang

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('user_id');

    if (userId != null) {
      final user = await ExcashDatabase.instance.getUserById(userId!);
      if (user != null) {
        setState(() {
          emailController.text = user.email;
          fullNameController.text = user.fullName;
          businessNameController.text = user.businessName;
          password = user.password; // Simpan password lama
          if (user.image != null) {
            _image = File(user.image!);
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (userId == null) return;

    final updatedUser = User(
      id: userId,
      email: emailController.text,
      fullName: fullNameController.text,
      businessName: businessNameController.text,
      password: password ?? '', // Gunakan password lama jika tidak diubah
      image: _image?.path ?? 'default.png', // Gunakan default jika null
    );

    await ExcashDatabase.instance.updateUser(updatedUser);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', updatedUser.email);
    prefs.setString('user_name', updatedUser.fullName);
    prefs.setString('user_business_name', updatedUser.businessName);
    if (_image != null) {
  prefs.setString('user_profile_image', _image!.path); // Samakan kunci dengan ProfilePage
}


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null ? const Icon(Icons.camera_alt, size: 50) : null,
              ),
            ),
            const SizedBox(height: 16),
            buildTextField("Email", emailController),
            const SizedBox(height: 16),
            buildTextField("Nama Lengkap", fullNameController),
            const SizedBox(height: 16),
            buildTextField("Nama Usaha", businessNameController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1E1E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
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
