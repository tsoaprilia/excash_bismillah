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
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  File? _image;
  String? userId;
  String? password;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id');

    if (userId != null) {
      final user = await ExcashDatabase.instance.getUserById(userId!);
      if (user != null) {
        setState(() {
          usernameController.text = user.username;
          fullNameController.text = user.fullName;
          businessNameController.text = user.businessName;
          businessAddressController.text = user.businessAddress;
          npwpController.text = user.npwp ?? '';
          phoneNumberController.text = user.phoneNumber;
          password = user.password;
          if (user.image != null) {
            _image = File(user.image!);
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
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
      username: usernameController.text,
      fullName: fullNameController.text,
      businessName: businessNameController.text,
      businessAddress: businessAddressController.text,
      npwp: npwpController.text.isEmpty ? null : npwpController.text,
      password: password ?? '',
      image: _image?.path ?? 'default.png',
       phoneNumber: phoneNumberController.text,
    );

    await ExcashDatabase.instance.updateUser(updatedUser);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_username', updatedUser.username);
    prefs.setString('user_name', updatedUser.fullName);
    prefs.setString('user_business_name', updatedUser.businessName);
    await prefs.setString('user_business_address', updatedUser.businessAddress);
    if (updatedUser.npwp != null) {
      await prefs.setString('user_npwp', updatedUser.npwp!);
    } else {
      await prefs.remove('user_npwp');
    }
    if (_image != null) {
      prefs.setString('user_profile_image', _image!.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil diperbarui")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Edit Profile",
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: SingleChildScrollView(
        // Make the whole body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFD39054), // Edit button color
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 18), // Edit icon
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            buildTextField("Nama Pengguna", usernameController),
            const SizedBox(height: 16),
            buildTextField("Nama Lengkap", fullNameController),
            const SizedBox(height: 16),
            buildTextField("Nama Usaha", businessNameController),
            const SizedBox(height: 24),
            buildTextField("Alamat Usaha", businessAddressController),
            const SizedBox(height: 16),
            buildTextField("NPWP (Opsional)", npwpController),
            const SizedBox(height: 24),
            buildTextField("Nomor Telepon", phoneNumberController),
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
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
            focusedBorder: OutlineInputBorder(
              // Border saat fokus
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD39054), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
