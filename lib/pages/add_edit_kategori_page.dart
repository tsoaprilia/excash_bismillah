import 'package:excash/database/excash_database.dart';
import 'package:excash/general_pages/menu.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/widgets/Ketegori_form_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _Id;
  String? _nameCategoryError;

  @override
  void initState() {
    super.initState();
    _nameCategory = widget.category?.name_category ?? '';
    _isUpdateForm = widget.category != null;
    _loadId();
  }

  // Memuat ID dari SharedPreferences
  Future<void> _loadId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _Id = prefs.getString('user_id'); // Pastikan menggunakan 'user_id'
    });
  }

  // Mengambil ID user dari SharedPreferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId =
        prefs.getString('user_id'); // Mengambil ID pengguna yang login
    print('User ID: $userId'); // Debugging
    return userId;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
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
                    onChangeNameCategory: (value) {
                      setState(() {
                        _nameCategory = value;
                        _nameCategoryError =
                            null; // Reset error saat input berubah
                      });
                    },
                    nameCategoryError: _nameCategoryError, // Tambahkan ini
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

  // Header dari halaman
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.event_note_outlined, color: Color(0xFF1E1E1E)),
            SizedBox(width: 8),
            Text(
              _isUpdateForm ? "Edit Kategori" : "Tambah Kategori",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
              ),
            )
          ],
        ),
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
                offset: Offset(0, 0),
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

  // Tombol simpan kategori
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            final userId = await _getUserId();

            if (userId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("User belum login")),
              );
              return;
            }

            try {
              if (_isUpdateForm) {
                await _updateCategory(); // Mengupdate kategori yang ada
                Navigator.pop(context); // Tutup halaman setelah update
              } else {
                // Cek jika kategori berhasil ditambahkan
                await _addCategory(userId);
                if (_nameCategoryError == null) {
                  Navigator.pop(
                      context); // Tutup halaman hanya jika tidak ada error
                }
              }
            } catch (e) {
              print('Error saat menambahkan kategori: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Terjadi kesalahan saat menyimpan kategori')),
              );
            }
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
          "Simpan Kategori",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Menambahkan kategori baru
  // Setelah berhasil menambah kategori, pastikan menggunakan pushReplacement
  Future<void> _addCategory(String userId) async {
    final category = Category(
      id: userId,
      name_category: _nameCategory,
      created_at_category: DateTime.now(),
      updated_at_category: DateTime.now(),
    );

    try {
      await ExcashDatabase.instance.create(category);
      // Jika berhasil, reset error
      setState(() {
        _nameCategoryError = null;
      });

      // Ganti halaman dengan pushReplacement setelah berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(initialIndex: 3),
        ), // Ganti dengan halaman yang sesuai
      );
    } catch (e) {
      // Tampilkan pesan error jika terjadi kesalahan
      setState(() {
        _nameCategoryError = e.toString().contains("sudah ada")
            ? "Kategori dengan nama '${_nameCategory}' sudah ada."
            : "Terjadi kesalahan saat menyimpan kategori.";
      });
      // Pesan kesalahan di UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_nameCategoryError!)),
      );
    }
  }

  // Mengupdate kategori yang sudah ada

  Future<void> _updateCategory() async {
    final updatedCategory = widget.category!.copy(
      id: widget.category!.id, // Tambahkan ini jika `id` wajib saat update
      name_category: _nameCategory,
      updated_at_category: DateTime.now(),
    );
    await ExcashDatabase.instance.updateCategory(updatedCategory);
  }
}
