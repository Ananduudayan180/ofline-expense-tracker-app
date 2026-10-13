import 'package:flutter/material.dart';

/// App color palette defined in Stitch design tokens (Tactile Utility theme)
class AppColors {
  AppColors._();

  // Primary Accent (High visibility Lime Green)
  static const Color primary = Color(0xFFC7F464);
  static const Color primaryDark = Color(0xFF4C6700);
  static const Color primaryDim = Color(0xFFAAD549);
  static const Color onPrimary = Color(0xFF252720);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);

  // Surface & Canvas
  static const Color background = Color(0xFFF9FAF6);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F0);
  static const Color surfaceContainer = Color(0xFFEDEEEA);
  static const Color surfaceContainerHigh = Color(0xFFE7E9E5);
  static const Color surfaceContainerHighest = Color(0xFFE2E3DF);
  static const Color surfaceDim = Color(0xFFD9DAD7);

  // Typography & Ink
  static const Color ink = Color(0xFF252720);
  static const Color textMuted = Color(0xFF74786A);
  static const Color textSubtle = Color(0xFF9EA295);

  // Borders & Dividers
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
}
