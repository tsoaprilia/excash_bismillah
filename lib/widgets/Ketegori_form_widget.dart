import 'package:flutter/material.dart';

class CategoryFormWidget extends StatelessWidget {
  const CategoryFormWidget({
    super.key,
    required this.nameCategory,
    required this.onChangeNameCategory,
  });

  final String nameCategory;
  final ValueChanged<String> onChangeNameCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Nama Kategori',
          //   style: TextStyle(
          //     fontSize: 16,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),

          const SizedBox(height: 8),
          _buildNameCategoryField(),
          // const SizedBox(height: 16),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     child: Text('Simpan'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildNameCategoryField() {
    return TextFormField(
      initialValue: nameCategory,
      style: const TextStyle(
        fontSize: 14, // Ukuran teks input lebih kecil
        fontWeight: FontWeight.w500, // Medium agar mirip dengan gambar
        color: Colors.black,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Sesuai gambar
          borderSide: const BorderSide(color: Colors.black), // Default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black), // Border normal
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFD39054), width: 2), // Border aktif
        ),
        prefixIcon: const IconTheme(
          data: IconThemeData(
              size: 18, opacity: 0.8), // Ukuran lebih kecil & opacity dikurangi
          child: const Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFF6C727F),
          ),
        ),

        hintText: 'Nama Kategori Produk',
        hintStyle: const TextStyle(
          fontSize: 12, // Ukuran placeholder
          fontWeight: FontWeight.w400, // Regular
          color: Color(0xFF6C727F), // Warna placeholder
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14), // Padding dalam
      ),
      onChanged: onChangeNameCategory,
      validator: (value) {
        return value != null && value.isEmpty
            ? 'Nama kategori tidak boleh kosong'
            : null;
      },
    );
  }
}
