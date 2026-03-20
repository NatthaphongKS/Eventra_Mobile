import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9E2D2F);
  static const Color primaryLight = Color(0xFFC04A4D);
  static const Color primaryDark = Color(0xFF6E1D1F);
  static const Color accent = Color(0xFFE16B6E);
  static const Color background = Color(0xFFFFF6F6);
  static const Color backgroundGradientStart = Color(0xFFFFD9DA);
  static const Color backgroundGradientEnd = Color(0xFFFFF3F3);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF221717);
  static const Color textSecondary = Color(0xFF7A6868);
  static const Color statusOngoing = Color(0xFF3F95F0);
  static const Color statusUpcoming = Color(0xFFF2BA39);
  static const Color statusDone = Color(0xFF4FAE73);
  static const Color inviteButton = Color(0xFFFF7070);
  static const Color divider = Color(0xFFF2E6E6);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Trebuchet MS',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.primary,
        fontSize: 23,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: AppColors.primary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.94),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}
