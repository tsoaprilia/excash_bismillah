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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Kategori',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      ),
    );
  }

  Widget _buildNameCategoryField() {
    return TextFormField(
      initialValue: nameCategory,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Kategori Barang',
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onChanged: onChangeNameCategory,
      validator: (value) {
        return value != null && value.isEmpty ? 'Kategori Barang tidak boleh kosong' : null;
      },
    );
  }
}
