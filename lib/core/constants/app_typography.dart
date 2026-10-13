import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Plus Jakarta Sans typography scale defined in Stitch Design Specs
class AppTypography {
  AppTypography._();

  static TextStyle get displayHero => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        letterSpacing: -1.2,
        color: AppColors.ink,
      );

  static TextStyle get displayHeroMobile => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 40 / 34,
        letterSpacing: -0.68,
        color: AppColors.ink,
      );

  static TextStyle get numericHero => GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        letterSpacing: -0.72,
        color: AppColors.ink,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 32 / 26,
        letterSpacing: -0.52,
        color: AppColors.ink,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 26 / 20,
        letterSpacing: -0.2,
        color: AppColors.ink,
      );

  static TextStyle get titleSm => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        color: AppColors.ink,
      );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.ink,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        color: AppColors.textMuted,
      );

  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 18 / 13,
        letterSpacing: 0.13,
        color: AppColors.ink,
      );

  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 14 / 11,
        letterSpacing: 0.33,
        color: AppColors.textMuted,
      );
}
