import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryLilac = Color(0xFFC8A2C8);
  static const Color secondaryPink = Color(0xFFFFE4E1);
  static const Color backgroundLight = Color(0xFFFFF9FF);
  static const Color backgroundDark = Color(0xFF1C1B1F);

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF4B0082),
    ),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w600),
    headlineSmall: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600),
    titleLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.black87),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.black54),
    labelLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
    displaySmall: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    titleLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    bodyLarge: GoogleFonts.roboto(fontSize: 16, color: Colors.white),
    bodyMedium: GoogleFonts.roboto(fontSize: 14, color: Colors.white70),
    labelLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLilac,
      primary: primaryLilac,
      onPrimary: Colors.white,
      secondary: secondaryPink,
      surface: backgroundLight,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: primaryLilac,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: primaryLilac,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: _textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLilac,
          foregroundColor: Colors.white,
          textStyle: _textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryLilac),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryLilac, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: secondaryPink, width: 2),
        ),
        labelStyle: const TextStyle(color: primaryLilac),
      ),
      cardTheme: const CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Colors.white,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryLilac,
      primary: primaryLilac,
      onPrimary: Colors.white,
      secondary: secondaryPink,
      surface: backgroundDark,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryLilac,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: _darkTextTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLilac,
          foregroundColor: Colors.white,
          textStyle: _darkTextTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: secondaryPink, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: Color(0xFF2C2C2E),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}