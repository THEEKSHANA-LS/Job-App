// lib/constants/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppColors is now dynamic — call AppColors.init(isDark) once when the
/// theme changes (done automatically by ThemeProvider) and every existing
/// `AppColors.xxx` reference across the app will resolve to the right
/// light/dark value without touching any screen file.
class AppColors {
  static bool _isDark = false;

  static void init(bool isDark) => _isDark = isDark;

  // ── Brand (same in both themes) ──────────────────────────────────────
  static const Color primary      = Color(0xFF2563EB);
  static const Color primaryDark  = Color(0xFF1D4ED8);
  static const Color secondary    = Color(0xFF10B981);
  static const Color accent       = Color(0xFFF59E0B);
  static const Color error        = Color(0xFFEF4444);
  static const Color success      = Color(0xFF22C55E);
  static const Color warning      = Color(0xFFF59E0B);

  // ── Adaptive (changes per theme) ───────────────────────────────────────
  static Color get primaryLight  => _isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE);
  static Color get background    => _isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
  static Color get surface       => _isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
  static Color get textPrimary   => _isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color get textSecondary => _isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textHint      => _isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  static Color get border        => _isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get divider       => _isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
}

class AppTheme {
  static ThemeData get lightTheme => _buildTheme(isDark: false);
  static ThemeData get darkTheme  => _buildTheme(isDark: true);

  static ThemeData _buildTheme({required bool isDark}) {
    final bg      = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surface = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final border  = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPri = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textSec = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final hint    = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return ThemeData(
      useMaterial3: true,
      brightness:   isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor:  AppColors.primary,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).apply(
        bodyColor:    textPri,
        displayColor: textPri,
      ),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation:        0,
        centerTitle:      true,
        titleTextStyle: GoogleFonts.inter(
          fontSize:   18,
          fontWeight: FontWeight.w600,
          color:      textPri,
        ),
        iconTheme: IconThemeData(color: textPri),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled:    true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: hint, fontSize: 14),
        labelStyle: TextStyle(color: textSec),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation:        0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: GoogleFonts.inter(
            fontSize:   15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color:    surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:         BorderSide(color: border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor:  isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
      ),
      dividerColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
    );
  }
}