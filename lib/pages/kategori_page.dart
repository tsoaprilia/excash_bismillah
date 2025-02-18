import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/add_edit_kategori_page.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:excash/widgets/kategori_card_widget.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Category> _categories;
  var _isLoading = false;

  Future<void> _refreshCategory() async {
    setState(() => _isLoading = true);
    _categories = await ExcashDatabase.instance.getAllCategory();
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
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
              width: 48, // Sesuaikan ukuran kotak agar proporsional
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12), // Border radius 12px
              ),
              child: Padding(
                padding: const EdgeInsets.all(14), // Padding 4px di semua sisi
                child: Image.asset(
                  'assets/img/excash_logo.png', // Sesuaikan dengan path file gambar
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain, // Pastikan gambar tidak terpotong
                ),
              ),
            ),
            Column(
              children: const [
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Color(0xFF757B7B), // Warna #757B7B
                    fontSize: 12, // Ukuran 12px
                    fontWeight: FontWeight.w600, // Semi-bold
                  ),
                ),
                Text(
                  "Aprilia Dwi Cristyana",
                  style: TextStyle(
                    color: Color(0xFF424242), // Warna #424242
                    fontSize: 12, // Ukuran 12px
                    fontWeight: FontWeight.w600, // Semi-bold
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
                    color: Colors.black
                        .withOpacity(0.1), // Warna shadow lebih soft
                    blurRadius: 8, // Efek shadow lebih lembut
                    spreadRadius: 0, // Tidak menyebar terlalu jauh
                    offset: Offset(0, 0), // Posisi shadow ke bawah
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons
                      .shopping_cart_outlined, // Gunakan versi outlined untuk garis
                  size: 24, // Ukuran ikon
                  color: Colors.black, // Warna ikon hitam
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductCartPage()),
                  );
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
                color: Colors.white, // Fill color FFFFFF
                borderRadius: BorderRadius.circular(10), // Border radius 10 px
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.1), // Warna shadow lebih soft
                    blurRadius: 8, // Efek shadow lebih lembut
                    spreadRadius: 0, // Tidak menyebar terlalu jauh
                    offset: const Offset(0, 0), // Posisi shadow
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari Kategori barang apa?',
                  hintStyle: const TextStyle(
                    color: Color(0xFF757B7B), // Warna hint text
                    fontSize: 12, // Ukuran teks 12 px
                    fontWeight: FontWeight.w400, // Regular
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1E1E1E), // Warna ikon search
                    size: 14, // Ukuran ikon 14 px
                  ),
                  filled: true,
                  fillColor: Colors.white, // Warna latar belakang input field
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Border radius 10 px
                    borderSide: BorderSide.none, // Tidak ada border
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
                    const SizedBox(
                        width: 6), // Beri jarak sedikit antara ikon dan teks
                    const Text(
                      'Kategori Saya',
                      style: TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontWeight: FontWeight.w600, // Semi bold
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      barrierColor: Colors
                          .transparent, // Agar background tidak full hitam
                      builder: (context) => const AddEditCategoryPage(),
                    );
                    _refreshCategory();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF1E1E1E), // Warna latar tombol
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Border radius 12
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    '+ Tambah',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500, // Medium
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                      ? const Center(child: Text('Kategori Kosong'))
                      : ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
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

// import 'package:excash/database/excash_database.dart';
// import 'package:excash/models/excash.dart';
// import 'package:excash/pages/add_edit_kategori_page.dart';
// import 'package:excash/widgets/kategori_card_widget.dart';
// import 'package:flutter/material.dart';

// class CategoryPage extends StatefulWidget {
//   const CategoryPage({super.key});

//   @override
//   State<CategoryPage> createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   late List<Category> _categorys;
//   var _isLoading = false;

//   Future<void> _refreshCategory() async {
//     setState(() {
//       _isLoading = true;
//     });
//     _categorys = await ExcashDatabase.instance.getAllCategory();
//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _refreshCategory();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Cateory'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: const Icon(Icons.add),
//         onPressed: () async {
//           await Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AddEditCategoryPage(),
//             ),
//           );
//           // Refresh categories after returning from Add/Edit page
//           _refreshCategory();
//         },
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : _categorys.isEmpty
//               ? const Center(child: Text('Kategori Kosong'))
//               : ListView.builder(
//                   itemCount: _categorys.length,
//                   itemBuilder: (context, index) {
//                     final category = _categorys[index];
//                     // Pass the refreshCategory method to CategoryCardWidget
//                     return CategoryCardWidget(
//                         category: category,
//                         index: index,
//                         refreshCategory:
//                             _refreshCategory); // Pass the method here
//                   }),
//     );
//   }
// }
