import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../widgets/animated_number.dart';
import 'dart:ui';
import 'dart:math' as math;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  String selectedPeriod = 'Bulan';
  final List<String> periods = ['Minggu', 'Bulan', 'Tahun'];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
            // ── App Bar ──
            _buildAppBar(),

            // ── Period Selector ──
            _buildPeriodSelector(),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: ValueListenableBuilder<double>(
                            valueListenable: AppState().expense,
                            builder: (context, expense, _) => _buildSummaryCard(
                              title: 'Total Keluar',
                              amountVal: expense,
                              percentage: '+12%',
                              isIncrease: true,
                              color: AppTheme.expenseRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ValueListenableBuilder<double>(
                            valueListenable: AppState().income,
                            builder: (context, income, _) => _buildSummaryCard(
                              title: 'Total Masuk',
                              amountVal: income,
                              percentage: '+5%',
                              isIncrease: true,
                              color: AppTheme.incomeGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Bar Chart
                    _buildWhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengeluaran Mingguan',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 160,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBar('Sen', 0.4, false),
                                _buildBar('Sel', 0.6, false),
                                _buildBar('Rab', 0.85, true),
                                _buildBar('Kam', 0.3, false),
                                _buildBar('Jum', 0.7, false),
                                _buildBar('Sab', 0.5, false),
                                _buildBar('Min', 0.2, false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Donut Chart
                    _buildWhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rincian Pengeluaran',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: AnimatedBuilder(
                                  animation: _animController,
                                  builder: (_, __) => CustomPaint(
                                    painter: DonutChartPainter(
                                      progress: _animController.value,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildLegend('Makan & Minum', '45%', const Color(0xFFFF7043)),
                                    _buildLegend('Belanja',        '25%', AppTheme.accentPurple),
                                    _buildLegend('Transport',      '15%', AppTheme.primaryGreenLight),
                                    _buildLegend('Tagihan',        '10%', AppTheme.expenseRed),
                                    _buildLegend('Lainnya',        '5%',  AppTheme.textSecondary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // AI Insight
                    _buildInsightCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: AppTheme.bgWhite,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Analisis',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.download_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ─── Period Selector ──────────────────────────────────────────────────────
  Widget _buildPeriodSelector() {
    return Container(
      color: AppTheme.bgWhite,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: periods.map((p) {
            final isSelected = selectedPeriod == p;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPeriod = p;
                    _animController.reset();
                    _animController.forward();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      p,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── Summary Card ─────────────────────────────────────────────────────────
  Widget _buildSummaryCard({
    required String title,
    required double amountVal,
    required String percentage,
    required bool isIncrease,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: AppTheme.shadowSoft, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                        color: color, size: 10),
                    Text(percentage,
                        style: TextStyle(
                            color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedNumber(
            value: amountVal,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ─── White Card wrapper ───────────────────────────────────────────────────
  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppTheme.shadowSoft, blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: child,
    );
  }

  // ─── Bar Chart ────────────────────────────────────────────────────────────
  Widget _buildBar(String label, double heightFactor, bool isHighest) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isHighest)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('850rb',
                style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
          ),
        AnimatedBuilder(
          animation: _animController,
          builder: (_, __) => Container(
            width: 30,
            height: 120 * heightFactor * _animController.value,
            decoration: BoxDecoration(
              gradient: isHighest
                  ? AppTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppTheme.textSecondary.withOpacity(0.25),
                        AppTheme.textSecondary.withOpacity(0.08),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isHighest ? AppTheme.primaryGreen : AppTheme.textSecondary,
            fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ─── Legend ───────────────────────────────────────────────────────────────
  Widget _buildLegend(String label, String pct, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
            ],
          ),
          Text(pct,
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── Insight Card (glassmorphism di atas putih) ───────────────────────────
  Widget _buildInsightCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withOpacity(0.08),
                AppTheme.primaryGreenLight.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.lightbulb_rounded,
                    color: AppTheme.primaryGreen, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rekomendasi Cerdas',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      'Pengeluaran Belanja kamu meningkat 20% bulan ini dibanding bulan lalu.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
class DonutChartPainter extends CustomPainter {
  final double progress;
  DonutChartPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;
    const strokeWidth = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    paint.color = const Color(0xFFEEF0F4);
    canvas.drawCircle(center, radius, paint);

    final segments = [
      {'color': const Color(0xFFFF7043), 'value': 0.45},
      {'color': AppTheme.accentPurple,   'value': 0.25},
      {'color': AppTheme.primaryGreenLight, 'value': 0.15},
      {'color': AppTheme.expenseRed,     'value': 0.10},
      {'color': AppTheme.textSecondary,  'value': 0.05},
    ];

    double currentAngle = -math.pi / 2;
    for (var seg in segments) {
      final sweep = (math.pi * 2 * (seg['value'] as double)) * progress;
      paint.color = seg['color'] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        sweep - 0.04,
        false,
        paint,
      );
      currentAngle += math.pi * 2 * (seg['value'] as double);
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Total\n',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        children: [
          TextSpan(
            text: '100%',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(DonutChartPainter old) => old.progress != progress;
}
