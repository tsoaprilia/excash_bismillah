import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/add_edit_kategori_page.dart';
import 'package:flutter/material.dart';

class CategoryCardWidget extends StatelessWidget {
  final Category category;
  final int index;
  final VoidCallback refreshCategory;  // Add this parameter

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.index,
    required this.refreshCategory,  // Initialize it in the constructor
  });

 void showNotificationDialog(BuildContext context, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Icon(
                    isSuccess
                        ? Icons.info_outline
                        : Icons.error_outline, 
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                    Text(
                      isSuccess ? 'Notifikasi Success' : 'Notifikasi Gagal',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                 Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      Image.asset(
                  isSuccess ? 'assets/img/sukses.png' : 'assets/img/gagal.png',
                  width: 60,
                  height: 60,
                ),
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
 Text(
                  isSuccess ? 'Berhasil Hapus data' : 'Gagal Hapus data',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 5),
              Text(
  isSuccess
      ? 'Selamat, anda berhasil menghapus data kategori produk!'
      : 'Maaf, anda belum berhasil menghapus data kategori produk!',
  textAlign: TextAlign.center,
  maxLines: 3, // Limit text to 2 lines
),
                    ])
                    
                  ],
                ),
                const SizedBox(height: 10),
              
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        title: Text(category.name_category,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${category.id_category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddEditCategoryPage(category: category)),
                ).then((value) => refreshCategory());  // Call refresh here
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool _isDeleteOperation = true; // Mark as delete operation
                try {
                  if (_isDeleteOperation) {
                    int success = await ExcashDatabase.instance
                        .deleteCategoryById(category.id_category!);
                    showNotificationDialog(context, success > 0);
                    // Call refreshCategory after deletion
                    refreshCategory();
                  } else {
                    // Implement other operations (update, add, etc.)
                  }
                } catch (e) {
                  showNotificationDialog(context, false); // Show failure notification if error
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
