import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../utils/currency_format.dart';
import 'auth_screen.dart';
import 'dart:ui';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;
  bool isNotificationsEnabled = true;
  bool isBiometricEnabled = false;

  @override
  Widget build(BuildContext context) {
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
                      'Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_rounded, color: AppTheme.textPrimary),
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
                  children: [
                    // ── Profile Card (glassmorphism di atas teal gradient) ──
                    _buildProfileCard(),
                    const SizedBox(height: 20),

                    // ── Stats ──
                    _buildStatsRow(),
                    const SizedBox(height: 28),

                    // ── Settings ──
                    _buildSettingsGroup(
                      title: 'Umum',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.person_outline_rounded,
                          title: 'Edit Profil',
                          color: AppTheme.primaryGreen,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Dompet Saya',
                          color: AppTheme.accentGreen,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.category_outlined,
                          title: 'Kategori',
                          color: AppTheme.accentPurple,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSettingsGroup(
                      title: 'Preferensi',
                      items: [
                        _buildSettingsToggle(
                          icon: Icons.dark_mode_outlined,
                          title: 'Mode Gelap',
                          color: Colors.indigoAccent,
                          value: isDarkMode,
                          onChanged: (v) => setState(() => isDarkMode = v),
                        ),
                        _buildSettingsToggle(
                          icon: Icons.notifications_outlined,
                          title: 'Notifikasi',
                          color: AppTheme.accentAmber,
                          value: isNotificationsEnabled,
                          onChanged: (v) => setState(() => isNotificationsEnabled = v),
                        ),
                        _buildSettingsToggle(
                          icon: Icons.fingerprint,
                          title: 'Kunci Biometrik',
                          color: AppTheme.incomeGreen,
                          value: isBiometricEnabled,
                          onChanged: (v) => setState(() => isBiometricEnabled = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSettingsGroup(
                      title: 'Bantuan',
                      items: [
                        _buildSettingsItem(
                          icon: Icons.help_outline_rounded,
                          title: 'Pusat Bantuan',
                          color: AppTheme.accentGreen,
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Kebijakan Privasi',
                          color: AppTheme.incomeGreen,
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Logout Button ──
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        AppState().reset();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const AuthScreen()),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.expenseRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.expenseRed.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Text(
                            'Keluar',
                            style: TextStyle(
                              color: AppTheme.expenseRed,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
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

  // ─── Profile Card ──────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          ValueListenableBuilder<String>(
            valueListenable: AppState().userName,
            builder: (_, name, __) {
              final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
              return Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.glassOnGreenGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.glassBorderLight),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          // Nama user dari AppState
          ValueListenableBuilder<String>(
            valueListenable: AppState().userName,
            builder: (_, name, __) => Text(
              name.isEmpty ? 'Pengguna' : name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<String>(
            valueListenable: AppState().userEmail,
            builder: (_, email, __) => Text(
              email.isEmpty ? '-' : email,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppTheme.shadowSoft,
              blurRadius: 12,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ValueListenableBuilder(
        valueListenable: AppState().transactions,
        builder: (_, transactions, __) {
          final totalTx  = transactions.length;
          final bulanAktif = _hitungBulanAktif();
          return Row(
            children: [
              Expanded(child: _buildStatItem('$bulanAktif', 'Bulan\nAktif')),
              Container(width: 1, height: 40, color: AppTheme.glassBorder),
              Expanded(child: _buildStatItem('$totalTx', 'Total\nTransaksi')),
              Container(width: 1, height: 40, color: AppTheme.glassBorder),
              Expanded(child: _buildStatItem(
                formatRupiahRingkas(AppState().balance.value),
                'Saldo\nSekarang',
              )),
            ],
          );
        },
      ),
    );
  }

  int _hitungBulanAktif() {
    final txs = AppState().transactions.value;
    if (txs.isEmpty) return 0;
    final months = txs.map((t) => '${t.date.year}-${t.date.month}').toSet();
    return months.length;
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 11, height: 1.3),
        ),
      ],
    );
  }

  // ─── Settings Group ────────────────────────────────────────────────────────
  Widget _buildSettingsGroup(
      {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgWhite,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.shadowSoft,
                  blurRadius: 12,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              return Column(
                children: [
                  entry.value,
                  if (i != items.length - 1)
                    Divider(
                        color: AppTheme.bgLight,
                        height: 1,
                        indent: 64,
                        endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary, size: 20),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title,
          style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }
}
