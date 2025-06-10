import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:excash/pages/home/home_page.dart';
import 'package:excash/pages/kategori_page.dart';
import 'package:excash/pages/product/product_page.dart';
import 'package:excash/pages/profile/profile_page.dart';
import 'package:excash/pages/transaction/transaction_page.dart';

class HalfCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, 0), radius: size.width / 2));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey _categoryShowcaseKey = GlobalKey();
  final GlobalKey _productShowcaseKey = GlobalKey();
  final GlobalKey _homeShowcaseKey = GlobalKey();
  final GlobalKey _transactionShowcaseKey = GlobalKey();
  final GlobalKey _profileShowcaseKey = GlobalKey();

  int _selectedIndex = 0;
  bool _showTutorial = false;
  int _currentTutorialStep = 0;
  List<GlobalKey> _tutorialKeys = [];

  final List<Widget> _pages = [
    HomePage(),
    CategoryPage(),
    ProductPage(),
    TransactionPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;

    if (!tutorialCompleted) {
      setState(() {
        _showTutorial = true;
        _tutorialKeys = [
          _categoryShowcaseKey,
          _productShowcaseKey,
          _homeShowcaseKey,
          _transactionShowcaseKey,
          _profileShowcaseKey
        ];
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTutorial();
      });
    }
  }

  void _startTutorial() {
    ShowCaseWidget.of(context)
        .startShowCase([_tutorialKeys[_currentTutorialStep]]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      if (_showTutorial && _currentTutorialStep < _tutorialKeys.length - 1) {
        _currentTutorialStep++;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ShowCaseWidget.of(context)
              .startShowCase([_tutorialKeys[_currentTutorialStep]]);
        });
      } else if (_showTutorial &&
          _currentTutorialStep == _tutorialKeys.length - 1) {
        _showTutorial = false;
        setTutorialCompleted();
      }
    });
  }

  // Menambahkan fungsi untuk set tutorial selesai
  Future<void> setTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('tutorial_completed', true);
  }

  BottomNavigationBarItem _buildNavItem(IconData iconOutlined,
      IconData iconFilled, int index, GlobalKey? showcaseKey) {
    final icon = Icon(_selectedIndex == index ? iconFilled : iconOutlined);
    if (showcaseKey != null &&
        _showTutorial &&
        showcaseKey == _tutorialKeys[_currentTutorialStep]) {
      String title = '';
      String description = '';

      if (showcaseKey == _categoryShowcaseKey) {
        title = 'Buat Kategori Dulu';
        description = 'Buat kategori produk Anda terlebih dahulu di sini';
      } else if (showcaseKey == _productShowcaseKey) {
        title = 'Tambahkan Produk';
        description = 'Tambahkan produk Anda setelah membuat kategori';
      } else if (showcaseKey == _homeShowcaseKey) {
        title = 'Order Disini!';
        description = 'Setelah ada produk, pelanggan bisa order di halaman ini';
      } else if (showcaseKey == _transactionShowcaseKey) {
        title = 'Cek Transaksi';
        description = 'Lihat semua transaksi yang terjadi di sini';
      } else if (showcaseKey == _profileShowcaseKey) {
        title = 'Profile Anda';
        description = 'Kelola akun dan pengaturan di sini';
      }

      return BottomNavigationBarItem(
        icon: Showcase(
          key: showcaseKey,
          title: title,
          description: description,
          titleTextStyle: const TextStyle(
            color: Color(0xFFD39054),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
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

  @override
  Widget build(BuildContext context) {
    double indicatorWidth = 20;
    double itemWidth = MediaQuery.of(context).size.width / 5;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            BottomNavigationBar(
              items: [
                _buildNavItem(
                    Icons.home_outlined, Icons.home, 0, _homeShowcaseKey),
                _buildNavItem(Icons.grid_view_outlined, Icons.grid_view, 1,
                    _categoryShowcaseKey),
                _buildNavItem(Icons.inventory_2_outlined, Icons.inventory_2, 2,
                    _productShowcaseKey),
                _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long,
                    3, _transactionShowcaseKey),
                _buildNavItem(
                    Icons.person_outline, Icons.person, 4, _profileShowcaseKey),
              ],
              currentIndex: _selectedIndex,
              backgroundColor: Colors.transparent,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color(0xFF757B7B),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              onTap: _onItemTapped,
            ),
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
}
