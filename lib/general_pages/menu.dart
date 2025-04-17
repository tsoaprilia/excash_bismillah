import 'package:excash/pages/home/home_page.dart';
import 'package:excash/pages/kategori_page.dart';
import 'package:excash/pages/product/product_page.dart';
import 'package:excash/pages/profile/profile_page.dart';
import 'package:excash/pages/transaction/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _homeShowcaseKey = GlobalKey();

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    CategoryPage(),
    ProductPage(),
    TransactionPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Menunda eksekusi hingga widget dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        _homeShowcaseKey,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    double indicatorWidth = 20; // Lebar indikator setengah lingkaran
    double itemWidth =
        MediaQuery.of(context).size.width / 5; // Hitung posisi ikon

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Warna background
          borderRadius: BorderRadius.circular(12), // Efek rounded
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BottomNavigationBar(
              items: [
                _buildNavItem(Icons.home_outlined, Icons.home, 0),
                _buildNavItem(Icons.grid_view_outlined, Icons.grid_view, 1),
                _buildNavItem(Icons.inventory_2_outlined, Icons.inventory_2, 2),
                _buildNavItem(
                    Icons.receipt_long_outlined, Icons.receipt_long, 3),
                _buildNavItem(Icons.person_outline, Icons.person, 4),
              ],
              currentIndex: _selectedIndex,
              backgroundColor: Colors.transparent, // Agar efek shadow terlihat
              selectedItemColor: Colors.white, // Warna icon saat aktif
              unselectedItemColor:
                  const Color(0xFF757B7B), // Warna icon saat tidak aktif
              type:
                  BottomNavigationBarType.fixed, // Menjaga ukuran tetap stabil
              elevation:
                  0, // Menghilangkan shadow default dari BottomNavigationBar
              onTap: _onItemTapped,
            ),

            // Indikator setengah lingkaran
            Positioned(
              bottom: 0,
              left: (_selectedIndex * itemWidth) +
                  (itemWidth / 2) -
                  (indicatorWidth / 2),
              child: ClipPath(
                clipper: HalfCircleClipper(),
                child: Container(
                  width: indicatorWidth,
                  height: indicatorWidth,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat item navigasi dengan ikon yang berubah
  BottomNavigationBarItem _buildNavItem(
      IconData iconOutlined, IconData iconFilled, int index) {
    final icon = Icon(_selectedIndex == index ? iconFilled : iconOutlined);

    if (index == 0) {
      // Hanya tambahkan ShowcaseView untuk Home
      return BottomNavigationBarItem(
        icon: Showcase(
          key: _homeShowcaseKey,
          title: 'Order Disini!',
          description: '', // tetap harus ada meskipun kosong
          titleTextStyle: const TextStyle(
            color: Color(0xFFD39054),
            fontSize: 15,
            fontWeight: FontWeight.w700,
           
          ),
          titleTextAlign: TextAlign.center,
          descTextStyle: const TextStyle(fontSize: 0), // hide desc
          child: icon,
        ),
        label: '',
      );
    }

    return BottomNavigationBarItem(
      icon: icon,
      label: '',
    );
  }
}

// Custom Clipper untuk membuat setengah lingkaran
class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    path = path.shift(Offset(0, size.height / 2)); // Geser ke bawah
    return path;
  }

  @override
  bool shouldReclip(HalfCircleClipper oldClipper) => false;
}
