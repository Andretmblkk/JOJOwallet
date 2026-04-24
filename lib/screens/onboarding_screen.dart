import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // 3 slide — masing-masing punya animasi Lottie berbeda
  final List<Map<String, dynamic>> _pages = [
    {
      'title':    'Kelola Keuangan Anda',
      'subtitle': 'Catat semua pemasukan dan pengeluaran dalam satu dasbor cerdas dengan pembaruan waktu nyata.',
      'lottie':   'assets/animations/Money.json',
    },
    {
      'title':    'Capai Target Anda',
      'subtitle': 'Tetapkan target tabungan dan pantau perkembangan uang Anda dengan sistem pelacakan interaktif.',
      'lottie':   'assets/animations/treasurer coin.json',
    },
    {
      'title':    'Aman & Terlindungi',
      'subtitle': 'Data keuangan Anda dienkripsi dan disimpan dengan aman menggunakan keamanan tingkat bank.',
      'lottie':   'assets/animations/Wallet _ Money Added.json',
    },
  ];

  void _goToAuth() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AuthScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          // Lingkaran dekorasi latar
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: 120, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGreen.withValues(alpha: 0.06),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Tombol Lewati ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _goToAuth,
                          child: Text(
                            'Lewati',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Animasi Lottie (area besar) ────────────────────────────
                SizedBox(
                  height: size.height * 0.42,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (p) => setState(() => _currentPage = p),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Lottie.asset(
                        _pages[i]['lottie'] as String,
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                ),

                // ── Card bawah (teks + navigasi) ───────────────────────────
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
                    decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowMedium,
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Teks (ikut halaman PageView animasi)
                        Column(
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _pages[_currentPage]['title'] as String,
                                key: ValueKey(_currentPage),
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      fontSize: 24,
                                      color: AppTheme.textPrimary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                _pages[_currentPage]['subtitle'] as String,
                                key: ValueKey('sub$_currentPage'),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      height: 1.6,
                                      color: AppTheme.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                        // Indikator + tombol
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dot indicator
                            Row(
                              children: List.generate(
                                _pages.length,
                                (i) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(right: 8),
                                  height: 8,
                                  width: _currentPage == i ? 24 : 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == i
                                        ? AppTheme.primaryGreen
                                        : AppTheme.glassBorder,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),

                            // Tombol Lanjut / Mulai
                            GestureDetector(
                              onTap: () {
                                if (_currentPage == _pages.length - 1) {
                                  _goToAuth();
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 28, vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen
                                          .withValues(alpha: 0.35),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Mulai'
                                      : 'Lanjut',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
