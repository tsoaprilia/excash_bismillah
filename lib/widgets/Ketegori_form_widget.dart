import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryFormWidget extends StatefulWidget {
  const CategoryFormWidget({
    super.key,
    required this.nameCategory,
    required this.onChangeNameCategory,
    this.nameCategoryError,
  });

  final String nameCategory;
  final ValueChanged<String> onChangeNameCategory;
  final String? nameCategoryError;

  @override
  _CategoryFormWidgetState createState() => _CategoryFormWidgetState();
}

class _CategoryFormWidgetState extends State<CategoryFormWidget> {
  int? Id;

  // Fungsi untuk mengambil user_id dari SharedPreferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_user');
    print('User ID: $userId'); // Debugging
    return userId;
  }

  @override
  void initState() {
    super.initState();
    _getUserId(); // Ambil user_id saat widget dibangun
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildNameCategoryField(),
          if (Id != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text("User ID: $Id"),
            ),
          // Button simpan atau aksi lain
        ],
      ),
    );
  }

  Widget _buildNameCategoryField() {
    return TextFormField(
      initialValue: widget.nameCategory,
      style: const TextStyle(
        fontSize: 14, // Ukuran teks input lebih kecil
        fontWeight: FontWeight.w500, // Medium agar mirip dengan gambar
        color: Colors.black,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD39054), width: 2),
        ),
        prefixIcon: const IconTheme(
          data: IconThemeData(size: 18, opacity: 0.8),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF6C727F),
          ),
        ),
        hintText: 'Nama Kategori Produk',
        errorText: widget.nameCategoryError,
        hintStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6C727F),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: widget.onChangeNameCategory,
      validator: (value) {
        return value != null && value.isEmpty
            ? 'Nama kategori tidak boleh kosong'
            : null;
      },
    );
  }
}
