import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: const Color(0xFFF5F9FF),
    cardColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: Colors.indigo,
      secondary: Colors.deepPurple,
      error: Colors.redAccent,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05), //withOpacity(0.05),
      margin: const EdgeInsets.all(16),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    cardColor: const Color(0xFF1C1F26),
    colorScheme: ColorScheme.dark(
      primary: Colors.indigoAccent,
      secondary: Colors.deepPurpleAccent,
      error: Colors.redAccent,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      margin: const EdgeInsets.all(16),
    ),
  );
}
