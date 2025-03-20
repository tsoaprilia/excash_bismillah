import 'package:excash/database/excash_database.dart';
import 'package:excash/models/order.dart';
import 'package:excash/models/order_detail.dart';
import 'package:excash/models/product.dart';
import 'package:excash/pages/product/product_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = "1 Bulan";
  final List<String> filters = ["1 Bulan", "3 Bulan", "1 Tahun"];
  Map<String, dynamic> incomeData = {};
  List<Map<String, dynamic>> topProducts = [];
  List<FlSpot> salesData = [];
  Database? _database;
  List<String> dateList = [];
  late Database db;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _fetchData();
    _fetchTopProducts();
  }

  Future<void> _initDatabase() async {
    db = await openDatabase(
        'excash.db'); // Gantilah dengan path database yang benar
    _fetchSalesData(); // Panggil setelah database siap
  }

  Future<void> _fetchTopProducts() async {
    final db = await ExcashDatabase.instance.database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT p.${ProductFields.name_product} AS name_product, 
           COALESCE(SUM(d.${OrderDetailFields.quantity}), 0) AS total_terjual
    FROM $tableOrderDetail d
    JOIN $tableProduct p ON d.${OrderDetailFields.id_product} = p.${ProductFields.id_product}
    JOIN $tableOrders o ON d.${OrderDetailFields.id_order} = o.${OrderFields.id_order}  
    WHERE o.${OrderFields.total_price} > 0  
    GROUP BY p.${ProductFields.name_product}
    ORDER BY total_terjual DESC
  ''');

    setState(() {
      topProducts = result;
    });
  }

  Future<Database> _getDatabase() async {
    if (_database != null) return _database!;
    _database = await openDatabase(join(await getDatabasesPath(), 'excash.db'));
    return _database!;
  }

  Future<void> _fetchData() async {
    final db = await ExcashDatabase.instance.database;

    // Tentukan tanggal hari ini dan tanggal pertama bulan ini dalam format 'YYYY-MM-DD'
    String today = DateTime.now().toIso8601String().split('T')[0];
    String firstDayOfMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1)
            .toIso8601String()
            .split('T')[0];

    await db.transaction((txn) async {
      var todayIncome = await txn.rawQuery(
          "SELECT SUM(total_price) as income, COUNT(id_order) as transactions FROM orders WHERE date(created_at) = ?",
          [today]);

      var monthIncome = await txn.rawQuery(
          "SELECT SUM(total_price) as income, COUNT(id_order) as transactions FROM orders WHERE date(created_at) >= ?",
          [firstDayOfMonth]);

      // Pastikan hasil query tidak null sebelum diakses
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

  Future<void> _fetchSalesData() async {
    if (db == null) return; // Pastikan db tidak null

    String dateFilter = "-1 month";
    if (selectedFilter == "3 Bulan") {
      dateFilter = "-3 month";
    } else if (selectedFilter == "1 Tahun") {
      dateFilter = "-1 year";
    }

    var sales = await db.rawQuery('''
    SELECT strftime('%d', created_at) AS day, 
           COALESCE(SUM(total_price), 0) AS total 
    FROM $tableOrders 
    WHERE date(created_at) >= date('now', ?)
    GROUP BY day
    ORDER BY day ASC
  ''', [dateFilter]);

    DateTime now = DateTime.now();
    int daysInRange = selectedFilter == "1 Tahun"
        ? 365
        : (selectedFilter == "3 Bulan" ? 90 : 30);

    List<FlSpot> tempSalesData = [];

    for (int i = 0; i < daysInRange; i++) {
      String day = (now.subtract(Duration(days: daysInRange - i)).day)
          .toString()
          .padLeft(2, '0');

      var matchingData = sales.firstWhere(
        (e) => e['day'] == day,
        orElse: () => {'day': day, 'total': 0},
      );

      tempSalesData.add(FlSpot(
        double.parse(matchingData['day'].toString()),
        double.parse(matchingData['total'].toString()),
      ));
    }

    if (tempSalesData.isEmpty) {
      tempSalesData.add(FlSpot(0, 0));
    }

    setState(() {
      salesData = tempSalesData;
    });
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Column(
              children: const [
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Color(0xFF757B7B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Aprilia Dwi Cristyana",
                  style: TextStyle(
                    color: Color(0xFF424242),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 24,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductCartPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(),
              const SizedBox(height: 20),
              _buildSalesPerformance(),
              const SizedBox(height: 20),
              _buildProductPerformance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _bigStatCard(
                    "Penghasilan Hari Ini",
                    incomeData?['hari_ini']?['income'] ?? "0",
                    "${incomeData?['hari_ini']?['transactions'] ?? "0"} transaksi")),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _bigStatCard(
                  "Penghasilan Bulan Ini",
                  incomeData!['bulan_ini']['income'],
                  "${incomeData!['bulan_ini']['transactions']} transaksi "),
            ),
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
            value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD39054)),
          ),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, color: Color(0xFF181717)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesPerformance() {
    DateTime now = DateTime.now(); // Definisi ulang di sini
    int daysInRange = selectedFilter == "1 Tahun"
        ? 365
        : (selectedFilter == "3 Bulan" ? 90 : 30);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Performa Penjualan",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: selectedFilter,
                onChanged: (newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                  _fetchSalesData(); // Tidak perlu parameter db jika variabelnya global
                },
                items: filters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          "${(value ~/ 1000).toString()}K",
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: selectedFilter == "1 Tahun"
                          ? 30
                          : (selectedFilter == "3 Bulan" ? 15 : 5),
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < daysInRange) {
                          String formattedDate = selectedFilter == "1 Tahun"
                              ? DateFormat('MMM').format(now.subtract(
                                  Duration(days: daysInRange - index)))
                              : DateFormat('dd/MM').format(now.subtract(
                                  Duration(days: daysInRange - index)));

                          return Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductPerformance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Performa Produk",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (topProducts.isEmpty)
          const Text(
            'Belum ada data produk terjual.',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
