import 'package:excash/pages/product/product_cart_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedFilter = "1 Bulan";
  final List<String> filters = ["1 Bulan", "3 Bulan", "1 Tahun"];

  String selectedYear = "2024"; // Default tahun
  final List<String> years = ["2024", "2025"];

  final Map<String, Map<String, dynamic>> incomeData = {
    "2024": {
      "hari_ini": {"income": "360.000", "transactions": "5", "items": "32"},
      "bulan_ini": {
        "income": "2.560.000",
        "transactions": "25",
        "items": "180"
      },
    },
    "2025": {
      "hari_ini": {"income": "280.000", "transactions": "4", "items": "25"},
      "bulan_ini": {
        "income": "2.100.000",
        "transactions": "20",
        "items": "150"
      },
    },
  };

  List<FlSpot> getSalesData() {
    if (selectedYear == "2024") {
      if (selectedFilter == "1 Bulan") {
        return [
          const FlSpot(1, 100000),
          const FlSpot(5, 150000),
          const FlSpot(10, 200000),
          const FlSpot(15, 250000),
          const FlSpot(20, 300000),
          const FlSpot(25, 400000),
          const FlSpot(30, 500000),
        ];
      } else if (selectedFilter == "3 Bulan") {
        return [
          const FlSpot(1, 120000),
          const FlSpot(15, 180000),
          const FlSpot(30, 250000),
          const FlSpot(45, 320000),
          const FlSpot(60, 450000),
          const FlSpot(75, 480000),
          const FlSpot(90, 500000),
        ];
      } else {
        return [
          const FlSpot(1, 150000),
          const FlSpot(30, 200000),
          const FlSpot(60, 300000),
          const FlSpot(90, 400000),
          const FlSpot(120, 500000),
          const FlSpot(130, 200000),
          const FlSpot(150, 400000),
          const FlSpot(170, 600000),
          const FlSpot(190, 700000),
        ];
      }
    } else {
      // Data untuk tahun 2025
      if (selectedFilter == "1 Bulan") {
        return [
          const FlSpot(1, 80000),
          const FlSpot(5, 120000),
          const FlSpot(10, 180000),
          const FlSpot(15, 230000),
          const FlSpot(20, 280000),
          const FlSpot(25, 350000),
          const FlSpot(30, 450000),
        ];
      } else if (selectedFilter == "3 Bulan") {
        return [
          const FlSpot(1, 100000),
          const FlSpot(15, 150000),
          const FlSpot(30, 220000),
          const FlSpot(45, 280000),
          const FlSpot(60, 400000),
          const FlSpot(75, 450000),
          const FlSpot(90, 480000),
        ];
      } else {
        return [
          const FlSpot(1, 140000),
          const FlSpot(30, 190000),
          const FlSpot(60, 280000),
          const FlSpot(90, 360000),
          const FlSpot(120, 470000),
          const FlSpot(130, 180000),
          const FlSpot(150, 380000),
          const FlSpot(170, 570000),
          const FlSpot(190, 690000),
        ];
      }
    }
  }

  final List<Map<String, dynamic>> topProducts = [
    {"rank": 1, "name": "Aqua", "sold": "600"},
    {"rank": 2, "name": "Sanco2l", "sold": "450"},
    {"rank": 3, "name": "teh pucuk", "sold": "200"},
  ];

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
              _buildYearFilter(),
              const SizedBox(height: 10),
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
                "Penghasilan",
                incomeData[selectedYear]!['hari_ini']['income'],
                "${incomeData[selectedYear]!['hari_ini']['transactions']} transaksi / ${incomeData[selectedYear]!['hari_ini']['items']} buah",
                "Kinerja Hari Ini",
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _bigStatCard(
                "Penghasilan",
                incomeData[selectedYear]!['bulan_ini']['income'],
                "${incomeData[selectedYear]!['bulan_ini']['transactions']} transaksi / ${incomeData[selectedYear]!['bulan_ini']['items']} buah",
                "Kinerja Bulan Ini",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bigStatCard(String title, String value, String desc, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(color: Color(0xFF1E1E1E), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF181717).withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
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
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildYearFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Tahun",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: selectedYear,
          onChanged: (newValue) {
            setState(() {
              selectedYear = newValue!;
            });
          },
          items: years.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSalesPerformance() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 0.0, vertical: 0.0), // Padding lebih seragam
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
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
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
                    spots: getSalesData(),
                    isCurved: true,
                    barWidth: 2, // Garis lebih tipis
                    color: const Color(0xFFD39054),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3, // Ukuran titik dikecilkan
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
        Column(
          children: topProducts.map((product) {
            return ListTile(
              leading: Container(
                width: 24, // Sesuaikan ukuran kotak
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFD39054),
                  borderRadius: BorderRadius.circular(8), // Radius 8
                ),
                alignment: Alignment.center,
                child: Text(
                  "${product['rank']}",
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              title: Text(product['name']),
              trailing: Text(
                "${product['sold']}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
