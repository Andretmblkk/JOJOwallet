import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'bouncy_button.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionItem(context, Icons.arrow_upward_rounded,   'Kirim',    AppTheme.primaryGreen),
          _buildActionItem(context, Icons.arrow_downward_rounded, 'Terima',   AppTheme.accentGreen),
          _buildActionItem(context, Icons.account_balance_wallet, 'Isi Ulang', AppTheme.accentBlue),
          _buildActionItem(context, Icons.qr_code_scanner,        'Bayar',    AppTheme.accentPurple),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color) {
    return Column(
      children: [
        BouncyButton(
          onTap: () {},
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.18), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontSize: 12,
              ),
        ),
      ],
    );
  }
}
