import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/transaction_item.dart';
import '../widgets/bouncy_button.dart';
import '../state/app_state.dart';
import '../utils/currency_format.dart';
import 'add_transaction_sheet.dart';
import 'profile_screen.dart';
import 'analytics_screen.dart';
import 'savings_goal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  // Definisi kategori utama untuk ringkasan (ikon + warna, jumlah dari AppState)
  final List<Map<String, dynamic>> _categoryDefs = [
    {'key': 'Makan & Minum', 'icon': Icons.restaurant_menu, 'label': 'Makan', 'color': const Color(0xFFFF7043)},
    {'key': 'Transport',     'icon': Icons.directions_car,  'label': 'Transport', 'color': AppTheme.primaryGreen},
    {'key': 'Belanja',       'icon': Icons.shopping_bag,    'label': 'Belanja', 'color': const Color(0xFF9C27B0)},
    {'key': 'Tagihan',       'icon': Icons.bolt,            'label': 'Tagihan', 'color': AppTheme.accentAmber},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            _buildHeader(),

            // ── SCROLLABLE CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Balance Card
                    const BalanceCard(),
                    const SizedBox(height: 24),

                    // Quick Actions (Top Up, Bayar, dsb)
                    const QuickActions(),
                    const SizedBox(height: 24),

                    // Layanan Utama (Style Gojek)
                    _buildServiceGrid(),
                    const SizedBox(height: 28),

                    // Ringkasan Kategori
                    _buildSectionHeader(
                      title: 'Ringkasan Kategori',
                      action: 'Lihat Semua',
                      onActionTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(),
                    const SizedBox(height: 28),

                    // Transaksi Terakhir
                    _buildSectionHeader(
                      title: 'Transaksi Terakhir',
                      action: 'Hari ini',
                      isActionButton: false,
                    ),
                    const SizedBox(height: 14),

                    // Daftar transaksi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ValueListenableBuilder<List<TransactionData>>(
                        valueListenable: AppState().transactions,
                        builder: (context, transactions, _) {
                          if (transactions.isEmpty) {
                            return _buildEmptyTransactions();
                          }
                          // Hanya tampilkan 5 transaksi terakhir di dashboard
                          final shown = transactions.take(5).toList();
                          return Column(
                            children: List.generate(shown.length, (i) {
                              return AnimatedBuilder(
                                animation: _animController,
                                builder: (ctx, child) {
                                  final delay = (i * 0.08).clamp(0.0, 0.6);
                                  final t = ((_animController.value - delay) /
                                          (1.0 - delay))
                                      .clamp(0.0, 1.0);
                                  return Opacity(
                                    opacity: t,
                                    child: Transform.translate(
                                      offset: Offset(0, 16 * (1 - t)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: TransactionItem(data: shown[i]),
                              );
                            }),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── BOTTOM NAV ──
      bottomNavigationBar: _buildBottomNav(),

      // ── FAB ──
      floatingActionButton: BouncyButton(
        onTap: () async {
          await AddTransactionSheet.show(context);
          // Reset animasi agar list transaksi baru muncul dengan mulus
          _animController.reset();
          _animController.forward();
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: AppTheme.bgWhite,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo + nama app
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      const Icon(Icons.account_balance_wallet, color: AppTheme.primaryGreen, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Salam + nama user
              ValueListenableBuilder<String>(
                valueListenable: AppState().userName,
                builder: (context, name, _) {
                  final greeting = _getGreeting();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        name.isEmpty ? 'JOJOdompet' : name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          // Notifikasi
          BouncyButton(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Belum ada notifikasi baru.'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.bgLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_none_rounded,
                      color: AppTheme.textPrimary, size: 24),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE74C3C),
                      shape: BoxShape.circle,
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

  // ─── Layanan Grid ──────────────────────────────────────────────────────────
  Widget _buildServiceGrid() {
    final List<Map<String, dynamic>> services = [
      {'icon': Icons.account_balance_rounded, 'label': 'Bank', 'color': const Color(0xFF00AED6)},
      {'icon': Icons.receipt_long_rounded,    'label': 'Tagihan', 'color': const Color(0xFFFFB400)},
      {'icon': Icons.savings_rounded,         'label': 'Tabungan', 'color': const Color(0xFF93328E)},
      {'icon': Icons.history_rounded,         'label': 'Riwayat', 'color': const Color(0xFF00AA13)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layanan JOJO',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: services.map((s) => _buildServiceItem(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    return BouncyButton(
      onTap: () {},
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (service['color'] as Color).withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(service['icon'] as IconData, color: service['color'] as Color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            service['label'] as String,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi 👋';
    if (hour < 15) return 'Selamat Siang 👋';
    if (hour < 18) return 'Selamat Sore 👋';
    return 'Selamat Malam 👋';
  }

  // ─── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String action,
    VoidCallback? onActionTap,
    bool isActionButton = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          if (isActionButton)
            GestureDetector(
              onTap: onActionTap,
              child: Text(
                action,
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            )
          else
            Text(
              action,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
        ],
      ),
    );
  }

  // ─── Category Grid (data dari AppState.categoryTotals) ────────────────────
  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ValueListenableBuilder<Map<String, double>>(
        valueListenable: AppState().categoryTotals,
        builder: (context, totals, _) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categoryDefs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.75,
            ),
            itemBuilder: (context, index) {
              final cat = _categoryDefs[index];
              final key   = cat['key'] as String;
              final amount = totals[key] ?? 0.0;
              return _buildCategoryCard(
                icon:   cat['icon'] as IconData,
                label:  cat['label'] as String,
                amount: amount,
                color:  cat['color'] as Color,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    // Format dengan pemisah ribuan yang benar
    final formatted = formatRupiahRingkas(amount);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSoft,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount == 0 ? 'Belum ada' : formatted,
                style: TextStyle(
                  color: amount == 0 ? AppTheme.textHint : AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────────────────────
  Widget _buildEmptyTransactions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, color: AppTheme.textHint, size: 52),
            const SizedBox(height: 14),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketuk tombol + untuk menambahkan\ntransaksi pertama Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowMedium,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded,      Icons.home_outlined,          'Beranda'),
              _buildNavItem(1, Icons.bar_chart_rounded, Icons.bar_chart_outlined,     'Analisis'),
              _buildNavItem(2, Icons.savings_rounded,   Icons.savings_outlined,       'Tabungan'),
              _buildNavItem(3, Icons.person_rounded,    Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData filledIcon, IconData outlineIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (index == 1) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const AnalyticsScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const SavingsGoalScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ProfileScreen(),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlineIcon,
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryGreen : AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
