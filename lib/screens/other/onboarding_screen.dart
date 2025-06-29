import 'package:flutter/material.dart';
import 'package:HarapanNews/screens/auth/login_screen.dart'; // Ganti dengan path ke LoginScreen Anda

// =========================================================================
// CATATAN: Pastikan Anda mengganti import di atas dengan path yang benar
// ke LoginScreen Anda agar tombol "Mulai" berfungsi.
// =========================================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Data untuk setiap halaman onboarding
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      icon: Icons.newspaper_outlined,
      title: "Berita Terkini di Ujung Jari Anda",
      description:
          "Dapatkan akses instan ke berita terbaru dari berbagai sumber terpercaya di seluruh dunia.",
    ),
    OnboardingPageData(
      icon: Icons.insights_rounded,
      title: "Analisis Mendalam & Terpercaya",
      description:
          "Jangan hanya membaca berita, pahami ceritanya. Kami menyajikan analisis mendalam untuk Anda.",
    ),
    OnboardingPageData(
      icon: Icons.notifications_active_outlined,
      title: "Jangan Ketinggalan Informasi",
      description:
          "Aktifkan notifikasi untuk mendapatkan pembaruan penting tentang topik yang Anda minati.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Tema gelap yang konsisten
      body: SafeArea(
        child: Column(
          children: [
            // Bagian utama yang bisa di-swipe (PageView)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Indikator halaman (titik-titik)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => buildDot(index, context),
                ),
              ),
            ),

            // Tombol navigasi
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: _buildNavigationButtons(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk tombol navigasi (Lanjut / Mulai)
  Widget _buildNavigationButtons() {
    bool isLastPage = _currentPage == _pages.length - 1;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child:
          isLastPage
              ? _buildActionButton(
                key: const ValueKey('start_button'),
                text: "Mulai Sekarang",
                onPressed: () {
                  // Navigasi ke halaman login dan hapus stack sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              )
              : _buildActionButton(
                key: const ValueKey('next_button'),
                text: "Lanjut",
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                },
              ),
    );
  }

  // Helper untuk membuat tombol
  Widget _buildActionButton({
    required Key key,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      key: key,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFFE94560),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.4),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Widget untuk membuat titik indikator yang beranimasi
  AnimatedContainer buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _currentPage == index ? 24 : 10, // Titik aktif lebih panjang
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFFE94560) : Colors.white38,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

// Model data untuk satu halaman onboarding
class OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// Widget untuk menampilkan konten satu halaman onboarding
class OnboardingPage extends StatefulWidget {
  final OnboardingPageData data;

  const OnboardingPage({super.key, required this.data});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten
        children: [
          // Animasi untuk ikon
          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE94560).withOpacity(0.1),
                ),
                child: Icon(
                  widget.data.icon,
                  color: const Color(0xFFE94560),
                  size: 100,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),

          // Animasi untuk teks
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  widget.data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.data.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
