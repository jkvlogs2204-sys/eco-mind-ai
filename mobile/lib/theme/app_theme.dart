import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors — Eco Emerald & Sage Palette
  static const Color primaryGreen = Color(0xFF0F5132);
  static const Color emeraldAccent = Color(0xFF198754);
  static const Color lightSage = Color(0xFFD1E7DD);
  static const Color darkSlate = Color(0xFF1E293B);
  static const Color cardBackground = Color(0xFFF8FAFC);

  // Status / Grade Colors
  static const Color gradeAPlus = Color(0xFF059669); // Emerald
  static const Color gradeA = Color(0xFF10B981);     // Green
  static const Color gradeB = Color(0xFF84CC16);     // Lime
  static const Color gradeC = Color(0xFFEAB308);     // Amber
  static const Color gradeD = Color(0xFFF97316);     // Orange
  static const Color gradeE = Color(0xFFEF4444);     // Red

  static Color getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
        return gradeAPlus;
      case 'A':
        return gradeA;
      case 'B':
        return gradeB;
      case 'C':
        return gradeC;
      case 'D':
        return gradeD;
      case 'E':
        return gradeE;
      default:
        return Colors.grey;
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: emeraldAccent,
        surface: cardBackground,
        background: const Color(0xFFF1F5F9),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F5F9),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
