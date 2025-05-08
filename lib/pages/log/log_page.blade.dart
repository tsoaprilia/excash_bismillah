import 'package:excash/models/log.dart';
import 'package:flutter/material.dart';
import 'package:excash/database/excash_database.dart';
import 'package:excash/widgets/log/log_card_widget.dart';
import 'package:excash/pages/log/detail_log_page.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final typeOptions = ['Semua', 'add', 'edit', 'delete'];

  List<LogActivity> _logs = [];
  List<LogActivity> _allLogs = [];
  bool _isLoading = false;

  String _selectedType = 'Semua';
  String _selectedUser = 'Semua';
  DateTimeRange? _selectedDateRange;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    setState(() => _isLoading = true);
    final logs = await ExcashDatabase.instance.getLogs();
    setState(() {
      _allLogs = logs;
      _logs = logs;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    List<LogActivity> filtered = _allLogs.where((log) {
      final matchesType = _selectedType == 'Semua' || log.type == _selectedType;
      final matchesUser = _selectedUser == 'Semua' || log.user == _selectedUser;
      final matchesDate = _selectedDateRange == null ||
          (DateTime.parse(log.date).isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              DateTime.parse(log.date).isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1))));
      final matchesSearch =
          log.operation.toLowerCase().contains(_searchText.toLowerCase()) ||
              log.type.toLowerCase().contains(_searchText.toLowerCase()) ||
              log.user.toLowerCase().contains(_searchText.toLowerCase());

      return matchesType && matchesUser && matchesDate && matchesSearch;
    }).toList();

    setState(() {
      _logs = filtered;
    });
  }
  

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uniqueUsers = _allLogs.map((e) => e.user).toSet().toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 24, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Log Aktivitas",
                style: TextStyle(
                  color: Color(0xFF424242),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Dropdown for 'Tipe'
                  _buildDropdown(
                    label: 'Tipe',
                    value: _selectedType,
                    items: ['Semua', 'add', 'edit', 'delete'],
                    onChanged: (val) {
                      setState(() => _selectedType = val!);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Dropdown for 'User'
                  _buildDropdown(
                    label: 'User',
                    value: _selectedUser,
                    items: ['Semua', ...uniqueUsers],
                    onChanged: (val) {
                      setState(() => _selectedUser = val!);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(width: 8),

                  // ElevatedButton for Date Range Picker
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: const Color(
                                  0xFFD39054), // Set the primary color (gold color)
                              colorScheme: ColorScheme.light(
                                  primary: const Color(
                                      0xFFD39054)), // Set the color scheme with gold color
                              primaryColorDark: const Color(
                                  0xFFD39054), // Ensure dark variants also use the gold color
                              buttonTheme: ButtonThemeData(
                                  textTheme: ButtonTextTheme.primary),
                              inputDecorationTheme: const InputDecorationTheme(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFD39054)),
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedDateRange = picked);
                        _applyFilters();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF1E1E1E), // Button background color
                      foregroundColor: Colors.white, // Icon color
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(
                          17), // Adjust button padding to ensure icon fits
                      minimumSize: const Size(
                          0, 50), // Set height but let the width auto adjust
                    ),
                    child: const Icon(Icons.date_range, size: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // List Log
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
                              id_log: log.id_log.toString(),
                              date: log.date,
                              type: log.type,
                              user: log.user,
                              username: log.username,
                              operation: log.operation,
                              onTap: () {
                                final log = _logs[index];

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LogDetailPage(
                                      id: log.id_log
                                          .toString(), // Convert the int? to String here
                                      date: log.date,
                                      type: log.type,
                                      user: log.user,
                                      username: log.username,
                                    ),
                                  ),
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
