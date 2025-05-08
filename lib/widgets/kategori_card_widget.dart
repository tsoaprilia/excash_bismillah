import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/pages/add_edit_kategori_page.dart';
import 'package:flutter/material.dart';

class CategoryCardWidget extends StatelessWidget {
  final Category category;
  final int index;
  final VoidCallback refreshCategory;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.index,
    required this.refreshCategory,
  });

  void showNotificationDialog(BuildContext context, bool isSuccess,
      {String? message}) {
    // Ensure the context is valid before showing the dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.white, // Ensure it's white
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Ensure it's white
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        color: const Color(0xFF424242), // Text color
                        size: 24,
                      ),
                      Expanded(
                        child: Text(
                          isSuccess
                              ? 'Notifikasi Berhasil'
                              : 'Notifikasi Gagal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF424242),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Close button with shadow
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Image (status or any other image you want to add)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        isSuccess
                            ? 'assets/img/sukses.png'
                            : 'assets/img/gagal.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSuccess
                                  ? 'Berhasil Hapus Data'
                                  : 'Gagal Hapus Data',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF424242),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message ??
                                  (isSuccess
                                      ? 'Selamat, Anda berhasil menghapus data kategori produk!'
                                      : 'Maaf, Anda belum berhasil menghapus data kategori produk!'),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xFF757B7B), // Soft text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white, // Pastikan warna ini tetap putih
      elevation: 0, // Hilangkan elevation bawaan
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Shadow lebih soft
              blurRadius: 5,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          // Agar border radius ListTile ikut 12px
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              category.name_category,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2DECC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFFD39054),
                      size: 16,
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddEditCategoryPage(category: category),
                        ),
                      ).then((_) {
                        refreshCategory(); // Panggil refresh setelah halaman AddEditCategoryPage ditutup
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBCBCBC),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF1E1E1E),
                      size: 16,
                    ),
                    onPressed: () async {
                      int success = await ExcashDatabase.instance
                          .deleteCategoryById(category.id_category!);

                      if (success == -1) {
                        // Show message for failed deletion because the category is in use
                        showNotificationDialog(
                          context,
                          false,
                          message:
                              "Kategori ini tidak bisa dihapus karena masih digunakan di tabel lain.",
                        );
                      } else {
                        showNotificationDialog(context, success > 0);
                        refreshCategory();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



