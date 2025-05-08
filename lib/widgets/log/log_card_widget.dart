import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import the intl package for date formatting

class LogCardWidget extends StatelessWidget {
  final String id_log;
  final String date;  // Ensure this is a String representing the date
  final String type;
  final String user;
  final String username;
  final String operation; // Operasi yang dilakukan (tabel yang diubah)
  final VoidCallback onTap;

  LogCardWidget({
    super.key,
    required this.id_log,
    required this.date,
    required this.type,
    required this.user,
    required this.username,
    required this.operation,
    required this.onTap,
  });

  // Convert the date to a human-readable format
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date); // Parse the date string to DateTime
      return DateFormat('d MMMM yyyy, HH:mm').format(parsedDate); // Format the DateTime
    } catch (e) {
      return date; // If parsing fails, return the original string
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _getTypeColor(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  id_log,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF181717),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(date),  // Use the formatted date here
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
                              username,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757B7B),
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
                              "Operasi: $operation",
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
