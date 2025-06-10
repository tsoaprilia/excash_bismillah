import 'package:flutter/material.dart';
import 'package:excash/general_pages/auth/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/img/slide1.png',
      'title': 'Pantau Penjualan, Ambil Keputusan Lebih Cepat',
      'desc': 'Kelola bisnis dengan data real-time',
    },
    {
      'image': 'assets/img/slide2.png',
      'title': 'Kelola Kategori & Produk Sekaligus',
      'desc': 'Kelola dengan pencarian & filter pintar',
    },
    {
      'image': 'assets/img/slide3.png',
      'title': 'Pilih Produk, Atur Jumlah, Langsung Order',
      'desc': 'Pemesanan hanya dalam satu halaman',
    },
  ];

  void _nextPage() async {
    if (_currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_complete', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final item = onboardingData[index];
              return Column(
                children: [
                  // Header: Skip
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                    ),
                  ),

                  // Gambar Full Width
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: EdgeInsets.zero, // biar benar-benar full
                      child: Image.asset(
                        item['image']!,
                        fit: BoxFit.contain, // <--- biar gak kepotong
                        width: double.infinity,
                      ),
                    ),
                  ),

                  // Judul dan Deskripsi
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item['desc']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6C727F),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              onboardingData.length,
                              (dotIndex) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentIndex == dotIndex ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentIndex == dotIndex
                                      ? const Color(0xFFD39054)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Tombol Lanjut / Mulai
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _nextPage,
                              child: Text(
                                _currentIndex == onboardingData.length - 1
                                    ? 'Mulai'
                                    : 'Lanjut',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
