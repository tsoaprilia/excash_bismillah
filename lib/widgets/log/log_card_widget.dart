import 'dart:math';

import 'package:flutter/material.dart';

class LogCardWidget extends StatelessWidget {
  final String id;
  final String date;
  final String type;
  final String user;
  final String email;
  final VoidCallback onTap;

  LogCardWidget({
    super.key,
    required this.id,
    required this.date,
    required this.type,
    required this.user,
    required this.email,
    required this.onTap,
  });

  Color _getTypeColor() {
    switch (type.toLowerCase()) {
      case 'delete':
        return const Color(0xFFFFE6E6);
      case 'edit':
        return const Color(0xFFFFF2CC);
      case 'add':
        return const Color(0xFFE6F7E6);
      default:
        return Colors.grey;
    }
  }

  Color _getTextColor() {
    switch (type.toLowerCase()) {
      case 'delete':
        return Colors.red;
      case 'edit':
        return const Color(0xFFD39054);
      case 'add':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  final List<Color> randomColors = [
    const Color(0xFFD39054),
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        randomColors[Random().nextInt(randomColors.length)];

    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IntrinsicHeight(
            // Pastikan tinggi mengikuti konten
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Membuat semua elemen memiliki tinggi yang sama
              children: [
                /// **Bagian Warna ID di Kiri**
                Container(
                  width: 6, // Lebar tetap
                  height: double.infinity, // Pastikan tinggi mengikuti parent
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),

                /// **Bagian Isi Card**
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// **ID, Tanggal Log & Tombol Hapus**
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  id,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF181717),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5A5A5A),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getTextColor(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// **Nama User & Email**
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 6, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              user,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF181717),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.circle,
                                size: 6, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757B7B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
