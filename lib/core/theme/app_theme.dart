import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ──────────────────────────────────────────────
  static const Color deepSpace   = Color(0xFF050714);
  static const Color cosmicBlue  = Color(0xFF0D1035);
  static const Color royalPurple = Color(0xFF4A1C8F);
  static const Color deepPurple  = Color(0xFF2D0F6B);
  static const Color starGold    = Color(0xFFFFD700);
  static const Color moonSilver  = Color(0xFFE8E8F0);
  static const Color roseGold    = Color(0xFFB76E79);
  static const Color celestialTeal = Color(0xFF00B4D8);
  static const Color cardBg      = Color(0xFF111336);
  static const Color cardBgLight = Color(0xFF1A1E4A);
  static const Color textPrimary = Color(0xFFF5F5FF);
  static const Color textSecondary = Color(0xFFB0B3D6);
  static const Color textMuted   = Color(0xFF6B6E99);
  static const Color divider     = Color(0xFF252850);
  static const Color successGreen = Color(0xFF00C896);
  static const Color errorRed    = Color(0xFFFF4757);

  // ── Gradients ──────────────────────────────────────────────────
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepSpace, cosmicBlue, Color(0xFF0E0B2E)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [royalPurple, deepPurple],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0077B6), celestialTeal],
  );

  static const LinearGradient roseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B1A3A), roseGold],
  );

  // ── Card Decoration ────────────────────────────────────────────
  static BoxDecoration get glassCard => BoxDecoration(
    color: cardBg.withValues(alpha: 0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: royalPurple.withValues(alpha: 0.3), width: 1),
    boxShadow: [
      BoxShadow(
        color: royalPurple.withValues(alpha: 0.1),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );

  static BoxDecoration get goldBorderCard => BoxDecoration(
    color: cardBg,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: starGold.withValues(alpha: 0.4),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: starGold.withValues(alpha: 0.08),
        blurRadius: 20,
        spreadRadius: 1,
      ),
    ],
  );

  // ── Dark Theme ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepSpace,
      colorScheme: const ColorScheme.dark(
        primary: royalPurple,
        secondary: starGold,
        surface: cardBg,
        onPrimary: textPrimary,
        onSecondary: deepSpace,
        onSurface: textPrimary,
        error: errorRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.outfit(
          color: textMuted,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalPurple,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: royalPurple, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBg,
        selectedItemColor: starGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 20,
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
      ),
    );
  }
}
