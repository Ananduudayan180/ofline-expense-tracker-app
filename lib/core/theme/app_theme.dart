import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const palette = AppColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primary,
        onPrimaryContainer: palette.onPrimary,
        secondary: palette.ink,
        onSecondary: Colors.white,
        error: palette.error,
        onError: Colors.white,
        surface: palette.background,
        onSurface: palette.ink,
        outline: palette.borderSubtle,
        surfaceContainerLow: palette.surfaceContainerLow,
        surfaceContainer: palette.surfaceContainer,
        surfaceContainerHigh: palette.surfaceContainerHigh,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.ink),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: palette.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    const palette = AppColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primary,
        onPrimaryContainer: palette.onPrimary,
        secondary: palette.ink,
        onSecondary: const Color(0xFF11130F),
        error: palette.error,
        onError: const Color(0xFF690005),
        surface: palette.surfaceCard,
        onSurface: palette.ink,
        outline: palette.borderSubtle,
        surfaceContainerLow: palette.surfaceContainerLow,
        surfaceContainer: palette.surfaceContainer,
        surfaceContainerHigh: palette.surfaceContainerHigh,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.ink),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: palette.ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
