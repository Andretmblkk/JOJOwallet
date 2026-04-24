import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // === Light Mode Colors (Referensi JOJOdompet) ===
  static const Color bgLight        = Color(0xFFF0F4F8); // background abu-abu sangat muda
  static const Color bgWhite        = Color(0xFFFFFFFF); // card putih
  static const Color bgCard         = Color(0xFFFFFFFF);
  
  static const Color textPrimary    = Color(0xFF1A2332); // teks gelap utama
  static const Color textSecondary  = Color(0xFF7A8A9E); // teks abu sekunder
  static const Color textHint       = Color(0xFFB0BEC5);

  // Warna Utama (Gojek/Grab Style)
  static const Color primaryGreen   = Color(0xFF00AA13); // Hijau Gojek
  static const Color primaryGreenDark = Color(0xFF008910);
  static const Color primaryGreenLight = Color(0xFF2ECC71);
  static const Color accentGreen    = Color(0xFF00C853);

  // Warna aksen lainnya
  static const Color incomeGreen    = Color(0xFF00C853);
  static const Color expenseRed     = Color(0xFFEE2737); // Merah Gojek/Grab
  static const Color accentAmber    = Color(0xFFFFB400);
  static const Color accentBlue     = Color(0xFF00AED6);
  static const Color accentPurple   = Color(0xFF93328E);

  // Glass (untuk card & elemen transparan)
  static const Color glassBorder    = Color(0x1A000000); 
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassWhite     = Color(0x99FFFFFF);

  // Shadow
  static Color shadowSoft           = const Color(0xFF1A2332).withOpacity(0.04);
  static Color shadowMedium         = const Color(0xFF1A2332).withOpacity(0.08);

  // ==================== Theme Data ====================
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgWhite, // Lebih bersih dengan putih murni
      primaryColor: primaryGreen,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 32),
        bodyLarge:    GoogleFonts.inter(color: textPrimary, fontSize: 16),
        bodyMedium:   GoogleFonts.inter(color: textSecondary, fontSize: 14),
      ),
      colorScheme: const ColorScheme.light(
        primary:    primaryGreen,
        secondary:  accentGreen,
        surface:    bgWhite,
        background: bgWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWhite,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  // ==================== Gradients ====================
  /// Gradient utama balance card
  static const LinearGradient balanceCardGradient = LinearGradient(
    colors: [primaryGreenDark, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient aksen hijau
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glassmorphism gradient
  static const LinearGradient glassOnGreenGradient = LinearGradient(
    colors: [Color(0x44FFFFFF), Color(0x11FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Glass putih ringan untuk card di background light
  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
