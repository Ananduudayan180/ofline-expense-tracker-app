import 'package:flutter/material.dart';

/// Spacing, padding, and corner radius tokens from Stitch Design Specs
class AppDimens {
  AppDimens._();

  // Spacing Tokens
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 20.0;
  static const double spaceXl = 32.0;

  // Screen Insets
  static const double margin = 20.0;
  static const double marginMobile = 16.0;
  static const double gutter = 16.0;

  // Corner Radii
  static const double radiusSm = 4.0;
  static const double radiusDefault = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // BorderRadius helpers
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderDefault = BorderRadius.all(Radius.circular(radiusDefault));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));
}
