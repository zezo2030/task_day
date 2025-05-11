import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    textTheme: GoogleFonts.poppinsTextTheme(),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      shadowColor: AppColors.primaryColor.withOpacity(0.1),
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGray,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.textLight.withOpacity(0.5),
      type: BottomNavigationBarType.fixed,
      elevation: 20,
      selectedIconTheme: const IconThemeData(size: 28),
      unselectedIconTheme: const IconThemeData(size: 24),
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
  );

  // Dark theme configuration
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    colorScheme: const ColorScheme.dark(
      primary: Colors.deepPurpleAccent,
      secondary: Colors.purpleAccent,
      surface: Color(0xFF2C3E50),
      background: Color(0xFF1A1A2E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white.withOpacity(0.05),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
      bodySmall: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  );
}
