import 'package:excash/database/excash_database.dart';
import 'package:excash/models/excash.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pie_chart/pie_chart.dart' as pc;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = "1 Bulan";
  final List<String> filters = ["1 Bulan", "3 Bulan", "1 Tahun"];
  String selectedMonthFilter = "";
  final List<String> months = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];
  List<Map<String, dynamic>> categorySales = [];
  Map<String, dynamic> incomeData = {};
  List<Map<String, dynamic>> topProducts = [];
  List<FlSpot> salesData = [];
  Database? _database;
  late Database db;

  String selectedYear = DateTime.now().year.toString();
  final List<String> years = ["2025", "2026", "2027"];

  @override
  void initState() {
    super.initState();

    int currentMonth = DateTime.now().month;
    selectedMonthFilter =
        months[currentMonth - 1]; // Initialize with the current month

    // Ensure selectedMonthFilter is valid (not out of range)
    if (months.indexOf(selectedMonthFilter) < 0) {
      selectedMonthFilter = months[0]; // Default to "Januari" if invalid
    }

    // Automatically fetch the data when the page loads
    _initDatabase(); // Initialize database and fetch data
    _fetchSalesData(); // Automatically fetch sales data
    _fetchData(); // Automatically fetch income data
    _fetchTopProducts(); // Automatically fetch top products
    _fetchCategorySales();
  }

  Future<void> _initDatabase() async {
    db = await openDatabase('excash.db');
    _fetchSalesData(); // Fetch sales data after the database is ready
    _fetchData(); // Fetch other necessary data after DB initialization
  }

  String formatRupiah(dynamic amount) {
    if (amount == null) return "0";
    try {
      final number = int.parse(amount.toString());
      final formatted = NumberFormat('#,##0', 'id_ID').format(number);
      return formatted;
    } catch (e) {
      return "0"; // Kalau gagal parsing, balikkan 0
    }
  }

  Future<void> _fetchTopProducts() async {
    final db = await ExcashDatabase.instance.database;

    String monthNumber =
        (months.indexOf(selectedMonthFilter) + 1).toString().padLeft(2, '0');

    final List<Map<String, dynamic>> result = await db.rawQuery(''' 
    SELECT p.${ProductFields.name_product} AS name_product, 
           COALESCE(SUM(d.${OrderDetailFields.quantity}), 0) AS total_terjual
    FROM $tableOrderDetail d
    JOIN $tableProduct p ON d.${OrderDetailFields.id_product} = p.${ProductFields.id_product}
    JOIN $tableOrders o ON d.${OrderDetailFields.id_order} = o.${OrderFields.id_order}  
    WHERE o.${OrderFields.total_price} > 0  
    AND strftime('%Y', o.${OrderFields.created_at}) = ?  
    AND strftime('%m', o.${OrderFields.created_at}) = ?  
    GROUP BY p.${ProductFields.name_product}
    ORDER BY total_terjual DESC
  ''', [selectedYear, monthNumber]);

    setState(() {
      topProducts = result;
    });
  }

  Future<void> _fetchSalesData() async {
    final database = await ExcashDatabase.instance.database;

    List<FlSpot> tempSalesData = [];
    List<String> monthsOfYear = [
      '01',
      '02',
      '03',
      '04',
      '05',
      '06',
      '07',
      '08',
      '09',
      '10',
      '11',
      '12'
    ];

    for (int i = 0; i < 12; i++) {
      String currentMonth = monthsOfYear[i];

      var sales = await database.rawQuery(''' 
      SELECT COALESCE(SUM(total_price), 0) AS total 
      FROM $tableOrders 
      WHERE strftime('%Y', created_at) = ? 
      AND strftime('%m', created_at) = ?
    ''', [selectedYear, currentMonth]);

      double totalSales = sales.isNotEmpty && sales[0]['total'] != null
          ? (sales[0]['total'] as num).toDouble()
          : 0.0;

      tempSalesData.add(FlSpot((i + 1).toDouble(), totalSales));
    }

    setState(() {
      salesData = tempSalesData;
    });
  }

  Future<void> _fetchData() async {
    final db = await ExcashDatabase.instance.database;

    String today = DateTime.now().toIso8601String().split('T')[0];

    // Convert month name to month number
    String monthNumber =
        (months.indexOf(selectedMonthFilter) + 1).toString().padLeft(2, '0');

    await db.transaction((txn) async {
      // Fetch today's income data
      var todayIncome = await txn.rawQuery(
        "SELECT SUM(total_price) as income, COUNT(id_order) as transactions FROM orders WHERE date(created_at) = ? AND strftime('%Y', created_at) = ? AND strftime('%m', created_at) = ?",
        [today, selectedYear, monthNumber],
      );

      // Fetch monthly income data
      var monthIncome = await txn.rawQuery(
        "SELECT SUM(total_price) as income, COUNT(id_order) as transactions FROM orders WHERE strftime('%Y', created_at) = ? AND strftime('%m', created_at) = ?",
        [selectedYear, monthNumber],
      );

      num todayIncomeValue =
          (todayIncome.isNotEmpty && todayIncome[0]['income'] != null)
              ? todayIncome[0]['income'] as num
              : 0;

      int todayTransactions =
          (todayIncome.isNotEmpty && todayIncome[0]['transactions'] != null)
              ? todayIncome[0]['transactions'] as int
              : 0;

      num monthIncomeValue =
          (monthIncome.isNotEmpty && monthIncome[0]['income'] != null)
              ? monthIncome[0]['income'] as num
              : 0;

      int monthTransactions =
          (monthIncome.isNotEmpty && monthIncome[0]['transactions'] != null)
              ? monthIncome[0]['transactions'] as int
              : 0;

      setState(() {
        incomeData = {
          "hari_ini": {
            "income": todayIncomeValue.toString(),
            "transactions": todayTransactions.toString(),
          },
          "bulan_ini": {
            "income": monthIncomeValue.toString(),
            "transactions": monthTransactions.toString(),
          }
        };
      });
    });
  }

  Future<void> _fetchCategorySales() async {
    final db = await ExcashDatabase.instance.database;

    String monthNumber =
        (months.indexOf(selectedMonthFilter) + 1).toString().padLeft(2, '0');

    final List<Map<String, dynamic>> result = await db.rawQuery(''' 
    SELECT c.${CategoryFields.name_category} AS category_name, 
           COALESCE(SUM(d.${OrderDetailFields.quantity}), 0) AS total_terjual
    FROM $tableOrderDetail d
    JOIN $tableProduct p ON d.${OrderDetailFields.id_product} = p.${ProductFields.id_product}
    JOIN $tableCategory c ON p.${ProductFields.id_category} = c.${CategoryFields.id_category}
    JOIN $tableOrders o ON d.${OrderDetailFields.id_order} = o.${OrderFields.id_order}  
    WHERE o.${OrderFields.total_price} > 0  
    AND strftime('%Y', o.${OrderFields.created_at}) = ?  
    AND strftime('%m', o.${OrderFields.created_at}) = ?  
    GROUP BY c.${CategoryFields.name_category}
    ORDER BY total_terjual DESC
  ''', [selectedYear, monthNumber]);

    // If no data is found, set an empty list, and show message
    setState(() {
      categorySales = result.isEmpty ? [] : result;
    });
  }

  List<PieChartSectionData> _buildCategoryPieChart() {
    List<PieChartSectionData> sections = [];
    double totalSales = 0.0;

    // Calculate the total sales for all categories
    for (var category in categorySales) {
      totalSales += (category['total_terjual'] as num).toDouble();
    }

    // If no data, show a grey pie chart with the "No Data" message
    if (categorySales.isEmpty) {
      sections.add(PieChartSectionData(
        value: 100,
        color: Colors.grey, // Grey color when no data
        title: "No Data",
        radius: 50,
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      return sections;
    }

    // Limit to the top 3 categories and group others
    List<Map<String, dynamic>> topCategories = categorySales.take(3).toList();
    double othersTotal = 0.0;

    // Summing total for the top categories and the rest
    for (var category in topCategories) {
      totalSales += (category['total_terjual'] as num).toDouble();
    }

    // Add "Others" if there are more than 3 categories
    if (categorySales.length > 3) {
      for (var category in categorySales.skip(3)) {
        othersTotal += (category['total_terjual'] as num).toDouble();
      }
      topCategories
          .add({'category_name': 'Others', 'total_terjual': othersTotal});
    }

    // Create PieChartSectionData for the top categories
    for (var category in topCategories) {
      double percentage = totalSales > 0
          ? (category['total_terjual'] as num).toDouble() / totalSales * 100
          : 0;

      sections.add(PieChartSectionData(
        value: percentage,
        color: Color(0xFFD39054), // Color for pie sections
        title:
            '${category['category_name']} (${percentage.toStringAsFixed(1)}%)',
        radius: 60, // Increased size for better visibility
        titleStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }

    return sections;
  }

  Widget _buildCategoryPieChartWidget() {
    // Ambil 5 kategori teratas
    final topCategories = categorySales.take(3).toList();

    // Hitung total semua kategori
    final totalAll = categorySales.fold<double>(
        0, (sum, item) => sum + (item['total_terjual'] as num).toDouble());

    // Hitung total dari 5 kategori teratas
    final totalTop5 = topCategories.fold<double>(
        0, (sum, item) => sum + (item['total_terjual'] as num).toDouble());

    // Hitung sisanya untuk "Lainnya"
    final othersTotal = totalAll - totalTop5;

    // Buat dataMap
    Map<String, double> dataMap = {
      for (var item in topCategories)
        item['category_name']: (item['total_terjual'] as num).toDouble(),
      if (othersTotal > 0) 'Lainnya..': othersTotal,
    };

    // Daftar warna sesuai jumlah kategori
    final colorList = [
      Color(0xFF8C5C30), // Warna tua banget (shade)
      Color.fromARGB(255, 183, 118, 57), // Warna agak tua
      Color(0xFFD39054), // Warna utama
      Color.fromARGB(201, 248, 206, 166), // Warna sangat muda
    ];

    return pc.PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: 200,
      colorList: colorList.take(dataMap.length).toList(),
      initialAngleInDegree: 0,
      chartType: pc.ChartType.disc,
      ringStrokeWidth: 32,
      legendOptions: pc.LegendOptions(
        showLegendsInRow: false,
        legendPosition: pc.LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: pc.ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true, // <- tampilkan sebagai persen
        showChartValuesOutside: false,
        decimalPlaces: 0, // <- tampilkan sebagai 10%, bukan 10.0%
      ),
    );
  }

  Widget _buildCategorySales() {
    // Always display the "Kategori Terjual" text
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Kategori Produk Terlaris",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6), // Space after the title

        // If there is no data, show the "No Data" message
        if (categorySales.isEmpty)
          Text(
            'Belum ada data penjualan.',
          )

        // If there is data, show the pie chart
        else
          _buildCategoryPieChartWidget(), // Pie chart widget here
      ],
    );
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
                "Dashboard Reporting",
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildYearFilter(), // Tambahkan filter tahun di sini
              const SizedBox(height: 10),
              _buildStatsCards(),
              const SizedBox(height: 20),
              _buildSalesPerformance(),
              const SizedBox(height: 20),
              _buildCategorySales(),
              const SizedBox(height: 20),
              _buildProductPerformance(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD39054).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD39054).withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Pilih",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
          ),
          _buildDropdown(
            value: selectedYear,
            items: years,
            onChanged: (newYear) {
              setState(() {
                selectedYear = newYear!;
              });
              _fetchData();
              _fetchSalesData();
              _fetchTopProducts();
              _fetchCategorySales();
            },
          ),
          _buildDropdown(
            value: selectedMonthFilter,
            items: months,
            onChanged: (newMonth) {
              setState(() {
                selectedMonthFilter = newMonth!;
              });
              _fetchTopProducts();
              _fetchData();
              _fetchCategorySales();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: SizedBox(), // Ini tetap dipakai agar tidak ada underline
        items: items.map<DropdownMenuItem<String>>((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        // Row for "Penghasilan" text and DropdownButton
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Penghasilan",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // DropdownButton<String>(
            //   value: selectedMonthFilter,
            //   onChanged: (newMonthValue) {
            //     setState(() {
            //       selectedMonthFilter = newMonthValue!;
            //     });
            //     _fetchData(); // Update products when month changes
            //   },
            //   items: months.map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: _bigStatCard(
                "Hari Ini",
                incomeData != null && incomeData['hari_ini'] != null
                    ? "Rp ${formatRupiah(incomeData['hari_ini']['income']) ?? "0"}" // Menambahkan "Rp" di depan nilai
                    : "Rp 0", // Default ke "Rp 0" jika 'hari_ini' null
                "${incomeData != null && incomeData['hari_ini'] != null ? incomeData['hari_ini']['transactions'] ?? 0 : 0} transaksi", // Default ke 0 transaksi jika null
              ),
            ),
            const SizedBox(width: 10), // Space between the two cards
            Expanded(
              child: _bigStatCard(
                "Bulan Ini",
                incomeData != null && incomeData['bulan_ini'] != null
                    ? "Rp ${formatRupiah(incomeData['bulan_ini']['income']) ?? "0"}" // Menambahkan "Rp" di depan nilai
                    : "Rp 0", // Default ke "Rp 0" jika 'bulan_ini' null
                "${incomeData != null && incomeData['bulan_ini'] != null ? incomeData['bulan_ini']['transactions'] ?? 0 : 0} transaksi", // Default ke 0 transaksi jika null
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _bigStatCard(String title, String value, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0xFF181717).withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: const BorderSide(color: Color(0xFF1E1E1E), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF181717)),
          ),
          const SizedBox(height: 4),
          Text(
            value != null ? value : "0", // Null check for value
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD39054)),
          ),
          Text(
            desc != null
                ? desc
                : "No description", // Null check for description
            style: const TextStyle(fontSize: 12, color: Color(0xFF181717)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesPerformance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Performa Penjualan Tahunan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 250,
            child: salesData.isNotEmpty // Check if there's data to plot
                ? LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                "${(value ~/ 1000).toString()}K", // Format the sales value
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval:
                                1, // Show every month (1/1, 2/1, 3/1, ..., 12/1)
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int monthIndex =
                                  value.toInt() - 1; // Month index (0-11)
                              if (monthIndex < 0 || monthIndex > 11) {
                                return Text(""); // Avoid out of range access
                              }
                              return Text(
                                "${(monthIndex + 1).toString().padLeft(2, '0')}", // Format month with 2 digits
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: salesData,
                          isCurved: false,
                          barWidth: 2,
                          color: const Color(0xFFD39054),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 3,
                              color: const Color(0xFFD39054),
                              strokeWidth: 1,
                              strokeColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child:
                        Text("No data available")), // Show message if no data
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Produk Terlaris",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            // DropdownButton<String>(
            //   value: selectedMonthFilter,
            //   onChanged: (newMonthValue) {
            //     setState(() {
            //       selectedMonthFilter = newMonthValue!;
            //     });
            //     _fetchTopProducts(); // Update products when month changes
            //   },
            //   items: months.map<DropdownMenuItem<String>>((String value) {
            //     return DropdownMenuItem<String>(
            //       value: value,
            //       child: Text(value),
            //     );
            //   }).toList(),
            // ),
          ],
        ),
        const SizedBox(height: 10),
        if (topProducts.isEmpty)
          const Text(
            'Belum ada data produk terjual.',
          )
        else
          Column(
            children: topProducts
                .asMap()
                .entries
                .take(5) // ✅ Menampilkan hanya 5 produk teratas
                .map((entry) {
              final index = entry.key + 1; // Ranking manual
              final product = entry.value;
              final namaProduk =
                  product['name_product'] ?? 'Produk Tidak Diketahui';
              final totalTerjual = product['total_terjual'] ?? 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD39054),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$index",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  title: Text(
                    namaProduk,
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: Text(
                    "$totalTerjual",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
