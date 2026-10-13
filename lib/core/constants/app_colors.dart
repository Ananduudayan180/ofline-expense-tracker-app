import 'package:flutter/material.dart';

/// App color palette defined in Stitch design tokens (Tactile Utility theme)
class AppColors {
  AppColors._();

  // Static constant tokens for light theme (retained for backward compatibility and const widgets)
  static const Color primary = Color(0xFFC7F464);
  static const Color primaryDark = Color(0xFF4C6700);
  static const Color primaryDim = Color(0xFFAAD549);
  static const Color onPrimary = Color(0xFF252720);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);

  // Surface & Canvas (Light)
  static const Color background = Color(0xFFF9FAF6);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F0);
  static const Color surfaceContainer = Color(0xFFEDEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE7E9E5);
  static const Color surfaceContainerHighest = Color(0xFFE2E3DF);
  static const Color surfaceDim = Color(0xFFD9DAD7);

  // Typography & Ink (Light)
  static const Color ink = Color(0xFF252720);
  static const Color textMuted = Color(0xFF74786A);
  static const Color textSubtle = Color(0xFF9EA295);

  // Borders & Dividers (Light)
  static const Color borderSubtle = Color(0xFFE4E6DE);
  static const Color borderStrong = Color(0xFFCDD0C5);

  // Category & Graphic Accents
  static const Color catFood = Color(0xFFC7F464);
  static const Color catBills = Color(0xFF252720);
  static const Color catShopping = Color(0xFF747965);
  static const Color catTravel = Color(0xFFB8BDB0);
  static const Color catOther = Color(0xFFD6D9CE);

  // Status & Alerts
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF2E7D32);

  // Light theme color palette instance
  static const AppColorPalette light = AppColorPalette(
    isDark: false,
    primary: primary,
    primaryDark: primaryDark,
    primaryDim: primaryDim,
    onPrimary: onPrimary,
    onPrimaryDark: onPrimaryDark,
    background: background,
    surfaceCard: surfaceCard,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    surfaceDim: surfaceDim,
    ink: ink,
    textMuted: textMuted,
    textSubtle: textSubtle,
    borderSubtle: borderSubtle,
    borderStrong: borderStrong,
    catFood: catFood,
    catBills: catBills,
    catShopping: catShopping,
    catTravel: catTravel,
    catOther: catOther,
    error: error,
    errorContainer: errorContainer,
    success: success,
  );

  // Dark theme color palette instance (Tactile Utility Dark)
  static const AppColorPalette dark = AppColorPalette(
    isDark: true,
    primary: Color(0xFFC7F464), // High visibility electric lime
    primaryDark: Color(0xFFC7F464), // Pop accent for text/links in dark mode
    primaryDim: Color(0xFFAAD549),
    onPrimary: Color(0xFF1B2008), // Dark contrast on lime
    onPrimaryDark: Color(0xFFFFFFFF),
    background: Color(0xFF11130F), // Deep graphite charcoal canvas
    surfaceCard: Color(0xFF1B1E19), // Elevated dark tactile card
    surfaceContainerLow: Color(0xFF161914), // Subtle recessed surface
    surfaceContainer: Color(0xFF222620), // Mid-level container
    surfaceContainerHigh: Color(0xFF2B3028),
    surfaceContainerHighest: Color(0xFF353B31),
    surfaceDim: Color(0xFF161814),
    ink: Color(0xFFF3F5EE), // Crisp tactile off-white text
    textMuted: Color(0xFFA2A799), // Soft olive-grey text
    textSubtle: Color(0xFF767B6F),
    borderSubtle: Color(0xFF2B2F27), // Crisp dark border
    borderStrong: Color(0xFF3F4539),
    catFood: Color(0xFFC7F464),
    catBills: Color(0xFF8BAE78), // Sage olive for dark visibility
    catShopping: Color(0xFFB4BC9E),
    catTravel: Color(0xFF90988A),
    catOther: Color(0xFF656A60),
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
    success: Color(0xFF81C784),
  );

  /// Helper to get current palette based on BuildContext
  static AppColorPalette of(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return isDarkMode ? dark : light;
  }
}

/// Dynamic color palette container for theme switching
class AppColorPalette {
  final bool isDark;
  final Color primary;
  final Color primaryDark;
  final Color primaryDim;
  final Color onPrimary;
  final Color onPrimaryDark;
  final Color background;
  final Color surfaceCard;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceDim;
  final Color ink;
  final Color textMuted;
  final Color textSubtle;
  final Color borderSubtle;
  final Color borderStrong;
  final Color catFood;
  final Color catBills;
  final Color catShopping;
  final Color catTravel;
  final Color catOther;
  final Color error;
  final Color errorContainer;
  final Color success;

  const AppColorPalette({
    required this.isDark,
    required this.primary,
    required this.primaryDark,
    required this.primaryDim,
    required this.onPrimary,
    required this.onPrimaryDark,
    required this.background,
    required this.surfaceCard,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceDim,
    required this.ink,
    required this.textMuted,
    required this.textSubtle,
    required this.borderSubtle,
    required this.borderStrong,
    required this.catFood,
    required this.catBills,
    required this.catShopping,
    required this.catTravel,
    required this.catOther,
    required this.error,
    required this.errorContainer,
    required this.success,
  });
}

extension AppThemeContext on BuildContext {
  AppColorPalette get colors => AppColors.of(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
