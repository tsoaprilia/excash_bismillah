import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/product.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sellingPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  String? _selectedCategory;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        id_product: DateTime.now().millisecondsSinceEpoch.toString(),
        id_category: int.parse(_selectedCategory!),
        name_product: _nameController.text,
        price: int.parse(_priceController.text),
        selling_price: int.parse(_sellingPriceController.text),
        stock: int.parse(_stockController.text),
        description: _descriptionController.text,
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
        image_product: _image?.path ?? '',
      );

      await ExcashDatabase.instance.createProduct(newProduct);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah Produk")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: _image == null
                      ? Container(
                          height: 150,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.camera_alt),
                        )
                      : Image.file(_image!, height: 150),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Nama Produk"),
                ),
                DropdownButtonFormField(
                  value: _selectedCategory,
                  items: [DropdownMenuItem(child: Text("Kategori 1"), value: "1")],
                  onChanged: (value) => setState(() => _selectedCategory = value as String?),
                  decoration: InputDecoration(labelText: "Kategori Produk"),
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: "Harga Beli"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _sellingPriceController,
                  decoration: InputDecoration(labelText: "Harga Jual"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _stockController,
                  decoration: InputDecoration(labelText: "Stok Produk"),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Deskripsi"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProduct,
                  child: Text("Tambah Produk"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
