import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/product.dart';
import 'package:excash/widgets/product/product_form_widget.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;
  final Future<void> Function() refreshProducts; // Add this callback

  const AddEditProductPage(
      {super.key, this.product, required this.refreshProducts});

  @override
  _AddEditProductPageState createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idProductController;

  late String _idProduct;
  late String _name;
  late String _price;
  late String _sellingPrice;
  late String _stock;
  late String _description;
  late String? _selectedCategory;
  // File? _image;
  late bool _isUpdateForm;
  bool _isDisabled = false;

  String? _nameCategoryError;

  @override
  @override
  void initState() {
    super.initState();
    _isUpdateForm = widget.product != null;
    _idProduct = widget.product?.id_product ?? '';
    _idProductController = TextEditingController(text: _idProduct);
    _name = widget.product?.name_product ?? '';
    _price = widget.product?.price.toString() ?? '';
    _sellingPrice = widget.product?.selling_price.toString() ?? '';
    _stock = widget.product?.stock.toString() ?? '';
    _description = widget.product?.description ?? '';
    _selectedCategory = widget.product?.id_category != null
        ? widget.product!.id_category.toString()
        : null;
    _isDisabled = widget.product?.is_disabled ?? false;
  }

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('user_id'); // Mengambil ID pengguna yang login
    print('User ID: $userId'); // Debugging
    return userId;
  }

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Batal",
      true,
      ScanMode.BARCODE,
    );

    if (barcodeScanRes != '-1') {
      setState(() {
        _idProduct = barcodeScanRes;
        _idProductController.text = barcodeScanRes;
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "✅ Berhasil Scan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ID Produk berhasil dideteksi:",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  barcodeScanRes,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD39054), // Replaced with 0xFFD39054 color
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xFFD39054), // Replaced with 0xFFD39054 color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                  child: const Text("OK"),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final userId = await _getUserId(); // Ambil userId

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User belum login")),
        );
        return;
      }

      // Cek apakah nama produk sudah ada
      final db = await ExcashDatabase.instance.database;
      final existingProduct = await db.query(
        tableProduct,
        where:
            'LOWER(${ProductFields.name_product}) = ? AND ${ProductFields.id_product} != ?',
        whereArgs: [_name.toLowerCase(), _isUpdateForm ? _idProduct : ''],
      );

      if (existingProduct.isNotEmpty) {
        setState(() {
          _nameCategoryError = "Produk dengan nama '$_name' sudah ada";
        });
        return;
      }

      final newProduct = Product(
        id_product: _idProduct.isNotEmpty
            ? _idProduct
            : DateTime.now().millisecondsSinceEpoch.toString(),
        id_category: _selectedCategory != null
            ? int.tryParse(_selectedCategory!) ?? 0
            : 0,
        name_product: _name,
        price: _price.isNotEmpty ? int.parse(_price) : 0,
        selling_price: _sellingPrice.isNotEmpty ? int.parse(_sellingPrice) : 0,
        stock: _stock.isNotEmpty ? int.parse(_stock) : 0,
        description: _description,
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
        id: userId!, // Assign userId yang didapat dari SharedPreferences
        is_disabled: false, // Default to false if not set
      );

      if (_isUpdateForm) {
        await ExcashDatabase.instance.updateProduct(newProduct);
      } else {
        await ExcashDatabase.instance.createProduct(newProduct);
      }

      await widget.refreshProducts();
      Navigator.pop(context); // Tutup halaman setelah menyimpan
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ProductFormWidget(
                          idProduct: _idProduct,
                          idProductController: _idProductController,
                          name: _name,
                          nameCategoryError: _nameCategoryError,
                          category: _selectedCategory,
                          price: _price,
                          sellingPrice: _sellingPrice,
                          stock: _stock,
                          description: _description,
                          isEditMode: _isUpdateForm,
                          // image: _image,
                          onIdProductChanged: (value) =>
                              setState(() => _idProduct = value),
                          onNameChanged: (value) =>
                              setState(() => _name = value),
                          onCategoryChanged: (value) =>
                              setState(() => _selectedCategory = value),
                          onPriceChanged: (value) =>
                              setState(() => _price = value),
                          onSellingPriceChanged: (value) =>
                              setState(() => _sellingPrice = value),
                          onStockChanged: (value) =>
                              setState(() => _stock = value),
                          onDescriptionChanged: (value) =>
                              setState(() => _description = value),
                          // onPickImage: _pickImage,
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        _buildScanButton(),
                        const SizedBox(height: 10),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.add_shopping_cart, color: Color(0xFF1E1E1E)),
            SizedBox(width: 8),
            Text(
              _isUpdateForm ? "Edit Produk" : "Tambah Produk",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF424242)),
            ),

            // Text(
            //   "Tambah Produk",
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //     color: Color(0xFF424242),
            //   ),
            // ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildScanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _scanBarcode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFD39054),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "Scan Barcode",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "Simpan Produk",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
