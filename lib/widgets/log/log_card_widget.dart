import 'package:flutter/material.dart';

class LogCardWidget extends StatelessWidget {
  final String id;
  final String date;
  final String type;
  final String user;
  final String email;
  final VoidCallback onTap; // Tambahkan parameter onTap

  const LogCardWidget({
    super.key,
    required this.id,
    required this.date,
    required this.type,
    required this.user,
    required this.email,
    required this.onTap, // Tambahkan parameter onTap
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Navigasi ketika diklik
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.white,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD39054),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    id,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181717),
                        ),
                      ),
                      const SizedBox(height: 4),
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
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF181717),
                      ),
                    ),
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
      ),
    );
  }
}
