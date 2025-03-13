import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:excash/database/excash_database.dart';
import 'package:excash/models/product.dart';
import 'package:excash/widgets/product/product_form_widget.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class AddEditProductPage extends StatefulWidget {
  final Product? product;

  const AddEditProductPage({super.key, this.product});

  @override
  _AddEditProductPageState createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late String _idProduct;
  late String _name;
  late String _price;
  late String _sellingPrice;
  late String _stock;
  late String _description;
  late String? _selectedCategory;
  // File? _image;
  late bool _isUpdateForm;

  @override
  @override
  void initState() {
    super.initState();
    _isUpdateForm = widget.product != null;
    _idProduct = widget.product?.id_product ?? '';
    _name = widget.product?.name_product ?? '';
    _price = widget.product?.price.toString() ?? '';
    _sellingPrice = widget.product?.selling_price.toString() ?? '';
    _stock = widget.product?.stock.toString() ?? '';
    _description = widget.product?.description ?? '';
    _selectedCategory = widget.product?.id_category != null
        ? widget.product!.id_category.toString()
        : null;
    // _image = (widget.product?.image_product ?? '').isNotEmpty
    //     ? File(widget.product!.image_product!)
    //     : null;
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await ImagePicker().pickImage(
  //     source: ImageSource.gallery,
  //     maxWidth: 800,
  //     maxHeight: 800,
  //   );
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }

  Future<void> _scanBarcode() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Warna garis pemindai (hex color)
        "Batal", // Tombol batal
        true, // Mode flash
        ScanMode.BARCODE, // Jenis pemindaian
      );

      if (!mounted) return;

      setState(() {
        _idProduct = barcodeScanRes != "-1"
            ? barcodeScanRes
            : DateTime.now().millisecondsSinceEpoch.toString();
      });
    } catch (e) {
      setState(() {
        _idProduct = DateTime.now().millisecondsSinceEpoch.toString();
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final newProduct = Product(
          id_product: _idProduct.isNotEmpty
              ? _idProduct
              : DateTime.now().millisecondsSinceEpoch.toString(),
          id_category: _selectedCategory != null
              ? int.tryParse(_selectedCategory!) ?? 0
              : 0,
          name_product: _name,
          price: _price.isNotEmpty ? int.parse(_price) : 0,
          selling_price:
              _sellingPrice.isNotEmpty ? int.parse(_sellingPrice) : 0,
          stock: _stock.isNotEmpty ? int.parse(_stock) : 0,
          description: _description,
          created_at: DateTime.now(),
          updated_at: DateTime.now(),
          // image_product: _image?.path ?? '',
        );

        if (_isUpdateForm) {
          await ExcashDatabase.instance.updateProduct(newProduct);
        } else {
          await ExcashDatabase.instance.createProduct(newProduct);
        }

        if (mounted) {
          Navigator.pop(context); // Tutup loading
          Navigator.pop(context); // Tutup halaman
        }
      } catch (e) {
        if (mounted) Navigator.pop(context);
        print("❌ Error menyimpan produk: $e");
      }
    }
  }

//   Future<void> _saveProduct() async {
//     if (_formKey.currentState!.validate()) {
//       final newProduct = Product(
//         id_product: _idProduct.isNotEmpty
//             ? _idProduct
//             : DateTime.now().millisecondsSinceEpoch.toString(),
//         id_category: _selectedCategory != null
//             ? int.tryParse(_selectedCategory!) ?? 0
//             : 0,
//         name_product: _name,
//         price: _price.isNotEmpty ? int.parse(_price) : 0,
//         selling_price: _sellingPrice.isNotEmpty ? int.parse(_sellingPrice) : 0,
//         stock: _stock.isNotEmpty ? int.parse(_stock) : 0,
//         description: _description,
//         created_at: DateTime.now(),
//         updated_at: DateTime.now(),
//         image_product: _image?.path ?? '',
//       );

// //       final newProduct = Product(
// //   id_product: _idProduct.isNotEmpty ? _idProduct : DateTime.now().millisecondsSinceEpoch.toString(),
// //   id_category: _selectedCategory != null ? int.parse(_selectedCategory!) : 0,
// //   name_product: _name,
// //   price: int.parse(_price),
// //   selling_price: int.parse(_sellingPrice),
// //   stock: int.parse(_stock),
// //   description: _description,
// //   created_at: DateTime.now(),
// //   updated_at: DateTime.now(),
// //   image_product: _image?.path ?? '',
// // );

//       if (_isUpdateForm) {
//         await ExcashDatabase.instance.updateProduct(newProduct);
//       } else {
//         await ExcashDatabase.instance.createProduct(newProduct);
//       }
//       if (mounted) {
//         Navigator.pop(context);
//       }
//     }
//   }

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
                          name: _name,
                          category: _selectedCategory,
                          price: _price,
                          sellingPrice: _sellingPrice,
                          stock: _stock,
                          description: _description,
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
              _isUpdateForm ? "Edit Produk: $_name" : "Tambah Produk",
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
