import 'package:excash/database/excash_database.dart';
import 'package:excash/main.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/add_edit_kategori_page.dart';
import 'package:excash/widgets/kategori_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? _fullName;
  late List<Category> _categories;
  var _isLoading = false;
  late List<Category> _filteredCategories;
  final TextEditingController _searchController = TextEditingController();

  // Mendapatkan nama pengguna dari SharedPreferences
  Future<void> _getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fullName = prefs.getString('user_name') ?? 'Guest';
    });
  }

Future<void> printCategoryData() async {
  final db = await ExcashDatabase.instance.database;

  // Query untuk mengambil semua data dari tabel category
  List<Map<String, dynamic>> categories = await db.query('category');

  // Debugging: Menampilkan hasil query di terminal
  print("Isi tabel category:");

  // Pastikan data ada, lalu tampilkan hasilnya
  if (categories.isNotEmpty) {
    categories.forEach((category) {
      print("ID: ${category['id_category']}, Name: ${category['name_category']}");
    });
  } else {
    print("Tabel category kosong.");
  }
}

  // Memuat kategori dan menyaring data
  Future<void> _refreshCategory() async {
  setState(() {
    _isLoading = true;
  });

  try {
    _categories = await ExcashDatabase.instance.getAllCategory();
    _filteredCategories = _categories.isNotEmpty ? _categories : [];

    // Debugging untuk memastikan data kategori berhasil diambil
    print("Data kategori berhasil diambil: $_categories");
  } catch (e) {
    print("Error saat mengambil data kategori: $e");
    _filteredCategories = []; // Set ke list kosong jika ada error
  }

  setState(() {
    _isLoading = false;
  });
}

  // Fungsi untuk filter kategori berdasarkan pencarian
  void _filterCategory(String query) {
    final filtered = _categories.where((category) {
      return category.name_category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredCategories = filtered;
    });
  }

  @override
  void initState() {
    super.initState();
    _getFullName();
    _searchController.addListener(() {
      _filterCategory(_searchController.text);
    });
    _refreshCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(
                  'assets/img/excash_logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _fullName ?? '',
                  style: TextStyle(
                    color: Color(0xFF424242),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                icon: Icon(
                  Icons.settings_outlined,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () async {
                  // Panggil fungsi izin
                  await requestStoragePermission();
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Kategori barang apa?',
                  hintStyle: const TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1E1E1E),
                    size: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_list_bulleted_outlined,
                      color: Color(0xFF1E1E1E),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Kategori Saya',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierColor: Colors.transparent,
                      builder: (context) => const AddEditCategoryPage(),
                    );
                    _refreshCategory();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    '+ Tambah',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredCategories.isEmpty
                      ? const Center(child: Text('Kategori Kosong'))
                      : ListView.builder(
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = _filteredCategories[index];
                            return CategoryCardWidget(
                              category: category,
                              index: index,
                              refreshCategory: _refreshCategory,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
