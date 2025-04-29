import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path; // Aliasing to avoid conflict
import 'package:flutter/material.dart'; // For BuildContext

class ProductFormWidget extends StatefulWidget {
  final String idProduct;
  final TextEditingController idProductController;
  final String name;
  final String? category;
  final String price;
  final String sellingPrice;
  final String stock;
  final String description;
  // final File? image;
  final ValueChanged<String> onIdProductChanged;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onPriceChanged;
  final ValueChanged<String> onSellingPriceChanged;
  final ValueChanged<String> onStockChanged;
  final ValueChanged<String> onDescriptionChanged;
    final bool isEditMode;
  // final VoidCallback onPickImage;

  const ProductFormWidget({
    super.key,
    required this.idProduct,
    required this.idProductController,
    required this.name,
    required this.category,
    required this.price,
    required this.sellingPrice,
    required this.stock,
    required this.description,
    // required this.image,
    required this.onIdProductChanged,
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
    required this.onSellingPriceChanged,
    required this.onStockChanged,
    required this.onDescriptionChanged,
     required this.isEditMode,
    // required this.onPickImage,
  });

  @override
  _ProductFormWidgetState createState() => _ProductFormWidgetState();
}

class _ProductFormWidgetState extends State<ProductFormWidget> {
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_user');
    print('User ID: $userId'); // Debugging
    return userId;
  }

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.idProduct);
    _nameController = TextEditingController(text: widget.name);
    _priceController = TextEditingController(text: widget.price);
    _sellingPriceController = TextEditingController(text: widget.sellingPrice);
    _stockController = TextEditingController(text: widget.stock);
    _descriptionController = TextEditingController(text: widget.description);
    _selectedCategory = widget.category;
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final databasePath = await getDatabasesPath();
      final dbPath = path.join(databasePath, 'excash.db');
      final db = await openDatabase(dbPath);
      final List<Map<String, dynamic>> categories =
          await db.query(tableCategory);

      if (categories.isEmpty) {
        print("🔴 Tidak ada kategori yang ditemukan di database.");
      } else {
        print("✅ Kategori berhasil diambil: $categories");
      }

      setState(() {
        _categories = categories;
      });

//tambah
      if (widget.category != null) {
        final foundCategory = categories.firstWhere(
          (cat) => cat['id_category'].toString() == widget.category,
          orElse: () => {},
        );

        if (foundCategory.isNotEmpty) {
          _selectedCategory = foundCategory['id_category'].toString();
        }
      }

      // if (widget.category != null) {
      //   _selectedCategory = categories
      //       .firstWhere(
      //         (cat) => cat['id'].toString() == widget.category,
      //         orElse: () => {},
      //       )
      //       .toString();
      // }
    } catch (e) {
      print("❌ Error saat mengambil kategori: $e");
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GestureDetector(
          //   onTap: widget.onPickImage,
          //   child: Container(
          //     height: 150,
          //     width: double.infinity,
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.black),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: widget.image == null
          //         ? const Center(child: Icon(Icons.add_a_photo, size: 40))
          //         : Image.file(widget.image!, fit: BoxFit.cover),
          //   ),
          // ),
          // const SizedBox(height: 16),
          _buildTextField(
              label: 'ID Produk',
              controller: widget.idProductController,
              onChanged: widget.onIdProductChanged,
               enabled: !widget.isEditMode, // Make the input field disabled
              backgroundColor: Colors.grey[200]),

          _buildTextField(
            label: 'Nama Produk',
            controller: _nameController,
            onChanged: widget.onNameChanged,
          ),
          _buildCategoryDropdown(),
          _buildTextField(
            label: 'Harga Beli',
            controller: _priceController,
            onChanged: widget.onPriceChanged,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            label: 'Harga Jual',
            controller: _sellingPriceController,
            onChanged: widget.onSellingPriceChanged,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            label: 'Stok Produk',
            controller: _stockController,
            onChanged: widget.onStockChanged,
            keyboardType: TextInputType.number,
          ),
          _buildTextField(
            label: 'Deskripsi',
            controller: _descriptionController,
            onChanged: widget.onDescriptionChanged,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    Color? backgroundColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: enabled
            ? null
            : () {
                // Show the alert if the ID field is tapped
                showDialog(
                  context:
                      context, // context from the widget tree (BuildContext)
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ID Produk Tidak Bisa Diubah'),
                      content: const Text('ID Produk ini tidak dapat diubah.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context)
                                .pop(); // Using BuildContext here
                          },
                        ),
                      ],
                    );
                  },
                );
              },
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true, // Fill the background with color
            fillColor: backgroundColor ?? Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Sesuai gambar
              borderSide:
                  const BorderSide(color: Colors.black), // Default border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.black), // Border normal
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFD39054), width: 2), // Border aktif
            ),
            labelText: label,
          ),
          onChanged: onChanged,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          inputFormatters: label == 'Stok Produk' // Cek jika input adalah stok
              ? [
                  FilteringTextInputFormatter.digitsOnly, // Hanya angka
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    // Validasi agar stok tidak kurang dari 0
                    if (int.tryParse(newValue.text) != null &&
                        int.parse(newValue.text) < 0) {
                      return oldValue; // Kembalikan nilai sebelumnya jika negatif
                    }
                    return newValue; // Jika valid, terima nilai baru
                  })
                ]
              : [],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['id_category'].toString(),
              child:
                  Text(category['name_category'] ?? "Kategori Tidak Diketahui"),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
            widget
                .onCategoryChanged(value); // Pastikan dikirim ke parent widget
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), // Sesuai gambar
              borderSide:
                  const BorderSide(color: Colors.black), // Default border
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.black), // Border normal
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFFD39054), width: 2), // Border aktif
            ),
            labelText: "Pilih Kategori",
          )),
    );
  }
}
