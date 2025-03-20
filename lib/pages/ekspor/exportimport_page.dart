import 'package:excash/pages/ekspor/exportdata.dart';
import 'package:excash/pages/impor/importdata.dart';
import 'package:flutter/material.dart';

class ExportImportPage extends StatelessWidget {
  const ExportImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final exportData = ExportData();
    final importData = ImportData();

    return Scaffold(
      appBar: AppBar(title: const Text('Export & Import Data')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await exportData.exportToCSV();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil diekspor!")));
              },
              child: const Text("Export CSV"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await importData.importFromCSV();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil diimpor!")));
              },
              child: const Text("Import CSV"),
            ),
          ],
        ),
      ),
    );
  }
}
