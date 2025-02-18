import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/widgets/Ketegori_form_widget.dart';
import 'package:flutter/material.dart';

class AddEditCategoryPage extends StatefulWidget {
  final Category? category;

  const AddEditCategoryPage({super.key, this.category});

  @override
  State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late String _nameCategory;
  late bool _isUpdateForm;

  @override
  void initState() {
    super.initState();
    _nameCategory = widget.category?.name_category ?? '';
    _isUpdateForm = widget.category != null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pop(context), // Tutup modal jika di luar area ditekan
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4), // Efek blur background
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: CategoryFormWidget(
                    nameCategory: _nameCategory,
                    onChangeNameCategory: (value) =>
                        setState(() => _nameCategory = value),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bagian header modal
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.event_note_outlined, color: Color(0xFF1E1E1E)),
            SizedBox(width: 8),
            Text(
              "Tambah Kategori",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Border radius 12px
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Warna shadow lebih soft
                blurRadius: 8, // Efek shadow lebih lembut
                spreadRadius: 0, // Tidak menyebar terlalu jauh
                offset: Offset(0, 0), // Posisi shadow ke bawah
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  /// Tombol simpan kategori
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            if (_isUpdateForm) {
              await _updateCategory();
            } else {
              await _addCategory();
            }
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text(
          "Tambah Kategori",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _addCategory() async {
    final category = Category(
      name_category: _nameCategory,
      created_at_category: DateTime.now(),
      updated_at_category: DateTime.now(),
    );
    await ExcashDatabase.instance.create(category);
  }

  Future<void> _updateCategory() async {
    final updatedCategory = widget.category!.copy(
      name_category: _nameCategory,
      updated_at_category: DateTime.now(),
    );
    await ExcashDatabase.instance.updateCategory(updatedCategory);
  }
}

// import 'package:excash/database/excash_database.dart';
// import 'package:excash/models/excash.dart';
// import 'package:excash/widgets/Ketegori_form_widget.dart';
// import 'package:flutter/material.dart';

// class AddEditCategoryPage extends StatefulWidget {
//   final Category? category;

//   const AddEditCategoryPage({super.key, this.category});

//   @override
//   State<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
// }

// class _AddEditCategoryPageState extends State<AddEditCategoryPage> {
//   final _formKey = GlobalKey<FormState>();
//   late String _nameCategory;
//   late bool _isUpdateForm;

//   @override
//   void initState() {
//     super.initState();
//     _nameCategory = widget.category?.name_category ?? '';
//     _isUpdateForm = widget.category != null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isUpdateForm ? 'Edit Category' : 'Add Category'),
//         actions: [_saveCategoryButton()],
//       ),
//       body: Form(
//         key: _formKey,
//         child: CategoryFormWidget(
//           nameCategory: _nameCategory,
//           onChangeNameCategory: (value) => setState(() => _nameCategory = value),
//         ),
//       ),
//     );
//   }

//   Widget _saveCategoryButton() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: ElevatedButton(
//         onPressed: () async {
//           if (_formKey.currentState!.validate()) {
//             if (_isUpdateForm) {
//               await _updateCategory();
//             } else {
//               await _addCategory();
//             }
//             Navigator.pop(context);
//           }
//         },
//         child: const Text('Save'),
//       ),
//     );
//   }

//   Future<void> _addCategory() async {
//     final category = Category(
//       name_category: _nameCategory,
//       created_at_category: DateTime.now(),
//       updated_at_category: DateTime.now(),
//     );
//     await ExcashDatabase.instance.create(category);
//   }

//   Future<void> _updateCategory() async {
//     final updatedCategory = widget.category!.copy(
//       name_category: _nameCategory,
//       updated_at_category: DateTime.now(),
//     );
//     await ExcashDatabase.instance.updateCategory(updatedCategory);
//   }
// }
