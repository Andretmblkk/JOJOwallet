import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import 'animated_number.dart';
import 'dart:ui';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppTheme.balanceCardGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withOpacity(0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- Top row: label + bulan -----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SALDO TOTAL',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
                // Badge bulan — glassmorphism di atas card teal
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppTheme.glassOnGreenGradient,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.glassBorderLight, width: 1),
                      ),
                      child: Text(
                        DateFormat('MMMM\nyyyy', 'id_ID').format(DateTime.now()),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----- Angka saldo -----
            ValueListenableBuilder<double>(
              valueListenable: AppState().balance,
              builder: (context, balance, _) {
                return AnimatedNumber(
                  value: balance,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                    height: 1.15,
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ----- Bottom row: Pemasukan & Pengeluaran -----
            // Ini memakai glassmorphism (sesuai permintaan: bagian depan card boleh glassmorphism)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.glassOnGreenGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.glassBorderLight, width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<double>(
                          valueListenable: AppState().income,
                          builder: (context, income, _) => _buildStatItem(
                            icon: Icons.arrow_downward_rounded,
                            label: 'PEMASUKAN',
                            value: income,
                            color: const Color(0xFF7FFFDC),
                          ),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.2),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        child: ValueListenableBuilder<double>(
                          valueListenable: AppState().expense,
                          builder: (context, expense, _) => _buildStatItem(
                            icon: Icons.arrow_upward_rounded,
                            label: 'PENGELUARAN',
                            value: expense,
                            color: const Color(0xFFFFB3B3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedNumber(
                value: value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
