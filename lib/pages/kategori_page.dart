import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/add_edit_kategori_page.dart';
import 'package:excash/widgets/kategori_card_widget.dart';
import 'package:flutter/material.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late List<Category> _categorys;
  var _isLoading = false;

  Future<void> _refreshCategory() async {
    setState(() {
      _isLoading = true;
    });
    _categorys = await ExcashDatabase.instance.getAllCategory();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditCategoryPage(),
            ),
          );
          // Refresh categories after returning from Add/Edit page
          _refreshCategory();
        },
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _categorys.isEmpty
              ? const Center(child: Text('Kategori Kosong'))
              : ListView.builder(
                  itemCount: _categorys.length,
                  itemBuilder: (context, index) {
                    final category = _categorys[index];
                    // Pass the refreshCategory method to CategoryCardWidget
                    return CategoryCardWidget(
                        category: category,
                        index: index,
                        refreshCategory: _refreshCategory); // Pass the method here
                  }),
    );
  }
}
