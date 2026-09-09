import 'package:flutter/material.dart';

import 'pharma_palette.dart';

class AppColors {
  // Brand colors (same in both modes).
  static const Color primary = Color(0xFF007A78);
  static const Color primaryDark = Color(0xFF005C5A);
  static const Color secondary = Color(0xFF0B7285);
  static const Color accent = Color(0xFF2FB3A6);

  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007A78), Color(0xFF0B7285)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Per-brightness palette. Registers a theme dependency so the calling
  /// widget rebuilds automatically when the light/dark theme changes.
  static PharmaPalette of(BuildContext context) =>
      Theme.of(context).extension<PharmaPalette>() ?? PharmaPalette.light;
}