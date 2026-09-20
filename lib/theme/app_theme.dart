import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Netflix Color Palette
  static const Color netflixRed = Color(0xFFE50914);
  static const Color netflixDark = Color(0xFF141414);
  static const Color netflixBlack = Color(0xFF000000);
  static const Color netflixGrey = Color(0xFF808080);
  static const Color netflixLightGrey = Color(0xFFB3B3B3);
  static const Color netflixWhite = Color(0xFFFFFFFF);
  static const Color netflixGold = Color(0xFFFFB800);
  static const Color cardGloss1 = Color(0xFF1F1F1F);
  static const Color cardGloss2 = Color(0xFF2A2A2A);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradient definitions
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x88000000),
      Color(0xFF141414),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient cardGlossGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A2A2A),
      Color(0xFF1A1A1A),
    ],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE50914),
      Color(0xFFB20710),
    ],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: netflixDark,
      primaryColor: netflixRed,
      colorScheme: const ColorScheme.dark(
        primary: netflixRed,
        secondary: netflixGold,
        surface: cardGloss1,
        onPrimary: netflixWhite,
        onSecondary: netflixBlack,
        onSurface: netflixWhite,
        error: netflixRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: netflixWhite,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: netflixWhite,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.outfit(
          color: netflixWhite,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.outfit(
          color: netflixWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: netflixLightGrey,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: netflixGrey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.outfit(
          color: netflixWhite,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          color: netflixWhite,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: netflixWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: netflixRed,
          foregroundColor: netflixWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF333333),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: netflixRed, width: 1.5),
        ),
        hintStyle: GoogleFonts.outfit(color: netflixGrey),
        labelStyle: GoogleFonts.outfit(color: netflixLightGrey),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardGloss2,
        selectedColor: netflixRed,
        labelStyle: GoogleFonts.outfit(color: netflixLightGrey, fontSize: 12),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerColor: const Color(0xFF333333),
      iconTheme: const IconThemeData(color: netflixWhite),
    );
  }
}
