import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_number.dart';
import '../widgets/bouncy_button.dart';
import '../utils/currency_format.dart';
import 'dart:ui';

class SavingsGoalScreen extends StatefulWidget {
  const SavingsGoalScreen({super.key});

  @override
  State<SavingsGoalScreen> createState() => _SavingsGoalScreenState();
}

class _SavingsGoalScreenState extends State<SavingsGoalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  // Target tabungan — awalnya kosong, user tambah via tombol +
  // Struktur: {title, target(double), current(double), icon, color, date}
  final List<Map<String, dynamic>> _goals = [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget  = _goals.fold<double>(0, (s, g) => s + (g['target'] as double));
    final totalCurrent = _goals.fold<double>(0, (s, g) => s + (g['current'] as double));
    final overallPct   = totalTarget == 0 ? 0.0 : totalCurrent / totalTarget;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Container(
              color: AppTheme.bgWhite,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_rounded,
                        color: AppTheme.textPrimary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Target Tabungan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list_rounded,
                        color: AppTheme.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary Card ──
                    _buildSummaryCard(overallPct, totalCurrent, totalTarget),
                    const SizedBox(height: 28),

                    Text(
                      'Daftar Target',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 14),

                    ..._goals.isEmpty
                        ? [_buildEmptyState()]
                        : _goals.map((g) => _buildGoalItem(g)).toList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BouncyButton(
        onTap: () => _showAddGoalDialog(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ─── Summary Card (teal gradient + glassmorphism progress) ────────────────
  Widget _buildSummaryCard(double pct, double current, double target) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.balanceCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL TABUNGAN',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              // Pct badge glassmorphism
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppTheme.glassOnGreenGradient,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.glassBorderLight),
                    ),
                    child: Text(
                      '${(pct * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedNumber(
            value: current,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 20),

          // Progress bar glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: AppTheme.glassOnGreenGradient,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.glassBorderLight),
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (_, __) => Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 7,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          LayoutBuilder(
                            builder: (ctx, cons) => Container(
                              width: cons.maxWidth * pct * _animController.value,
                              height: 7,
                              decoration: BoxDecoration(
                                color: const Color(0xFF7FFFDC),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7FFFDC).withOpacity(0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatRupiahRingkas(current)} tersimpan',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                        ),
                        Text(
                          'Target: ${formatRupiahRingkas(target)}',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Goal Item ─────────────────────────────────────────────────────────────
  Widget _buildGoalItem(Map<String, dynamic> goal) {
    final double progress = (goal['current'] as double) / (goal['target'] as double);
    final bool isCompleted = progress >= 1.0;
    final Color color = goal['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(goal['icon'] as IconData, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal['title'] as String,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCompleted ? 'Target tercapai! 🎉' : 'Target: ${goal["date"]}',
                      style: TextStyle(
                        color: isCompleted ? AppTheme.incomeGreen : AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tambah',
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatRupiah(goal['current'] as double),
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              Text(
                formatRupiah(goal['target'] as double),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animController,
            builder: (_, __) => Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                LayoutBuilder(
                  builder: (ctx, cons) => Container(
                    width: cons.maxWidth * progress * _animController.value,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                            color: color.withOpacity(0.35), blurRadius: 6),
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

  // ─── Empty State ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.savings_outlined, color: AppTheme.textHint, size: 56),
            const SizedBox(height: 16),
            Text(
              'Belum ada target tabungan',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ketuk tombol + untuk membuat\ntarget tabungan pertama Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Dialog Tambah Target ─────────────────────────────────────────────────
  void _showAddGoalDialog() {
    final nameCtrl    = TextEditingController();
    final targetCtrl  = TextEditingController();
    Color selectedColor = AppTheme.primaryGreen;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textHint,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Target Baru',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 16),
                _dialogField(controller: nameCtrl, hint: 'Nama target (cth: Dana Darurat)'),
                const SizedBox(height: 12),
                _dialogField(
                    controller: targetCtrl,
                    hint: 'Jumlah target (Rp)',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                // Pilih warna
                Text('Warna',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AppTheme.primaryGreen,
                    AppTheme.accentGreen,
                    AppTheme.accentAmber,
                    AppTheme.accentPurple,
                    AppTheme.incomeGreen,
                    Colors.pinkAccent,
                  ].map((c) => GestureDetector(
                    onTap: () => setModal(() => selectedColor = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: selectedColor == c
                            ? Border.all(color: AppTheme.textPrimary, width: 2.5)
                            : null,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final raw  = targetCtrl.text.replaceAll('.', '').replaceAll(',', '');
                      final target = double.tryParse(raw) ?? 0;
                      if (name.isEmpty || target <= 0) return;

                      setState(() {
                        _goals.add({
                          'title':   name,
                          'target':  target,
                          'current': 0.0,
                          'icon':    Icons.savings_rounded,
                          'color':   selectedColor,
                          'date':    '-',
                        });
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan Target',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textHint),
        filled: true,
        fillColor: AppTheme.bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
