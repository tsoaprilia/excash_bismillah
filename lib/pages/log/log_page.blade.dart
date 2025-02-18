import 'package:excash/database/excash_database.dart';
import 'package:excash/pages/log/detail_log_page.dart';
import 'package:excash/widgets/log/log_card_widget.dart';
import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late List<LogData> _logs;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logs = [
      LogData(
        id: "LOG123456",
        date: "14/06/2024 16:50",
        type: "add",
        user: "Aprilia Dwi Cristyana",
        email: "aprilia@example.com",
      ),
      LogData(
        id: "LOG123457",
        date: "14/06/2024 17:00",
        type: "delete",
        user: "Budi Santoso",
        email: "budi@example.com",
      ),
      LogData(
        id: "LOG123458",
        date: "14/06/2024 17:10",
        type: "edit",
        user: "Citra Lestari",
        email: "citra@example.com",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Log Aktivitas",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
                decoration: InputDecoration(
                  hintText: 'Cari Aktivitas',
                  hintStyle: const TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF1E1E1E),
                    size: 18,
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
           Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? const Center(child: Text('Log Kosong'))
                      : ListView.builder(
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            final log = _logs[index];
                            return LogCardWidget(
                              id: log.id,
                              date: log.date,
                              type: log.type,
                              user: log.user,
                              email: log.email,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LogDetailPage(
                                      id: log.id,
                                      date: log.date,
                                      type: log.type,
                                      user: log.user,
                                      email: log.email,
                                    ),
                                  )
                                );
                              },
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
        

class LogData {
  final String id;
  final String date;
  final String type;
  final String user;
  final String email;

  const LogData({
    required this.id,
    required this.date,
    required this.type,
    required this.user,
    required this.email,
  });
}
