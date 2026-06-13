import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color background = Color(0xFFFDF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFC0622A);
  static const Color primaryDark = Color(0xFF2C1A0E);
  static const Color accent = Color(0xFFE8834A);
  static const Color textPrimary = Color(0xFF2C1A0E);
  static const Color textSecondary = Color(0xFF9A7A60);
  static const Color textMuted = Color(0xFFC8B8A4);
  static const Color inputBg = Color(0xFFF5EDE5);
  static const Color border = Color(0xFFEDE4D8);
  static const Color userBubble = Color(0xFF2C1A0E);
  static const Color botBubble = Color(0xFFFFFFFF);
  static const Color userBubbleText = Color(0xFFFDF8F3);
  static const Color botBubbleText = Color(0xFF3D2A1A);
  static const Color error = Color(0xFFD32F2F);

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        shape: Border(
          bottom: BorderSide(color: border, width: 1),
        ),
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(color: textPrimary),
        displayMedium: GoogleFonts.playfairDisplay(color: textPrimary),
        displaySmall: GoogleFonts.playfairDisplay(color: textPrimary),
        headlineMedium: GoogleFonts.playfairDisplay(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.playfairDisplay(color: textPrimary, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.dmSans(color: textPrimary),
        bodyMedium: GoogleFonts.dmSans(color: textPrimary),
        labelSmall: GoogleFonts.spaceMono(color: textMuted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        hintStyle: GoogleFonts.dmSans(color: textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }
}