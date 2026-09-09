import 'package:flutter/material.dart';

/// Per-brightness palette resolved from the active [ThemeData].
/// Reading via [AppColors.of] registers a theme dependency so widgets
/// rebuild automatically when the theme changes.
@immutable
class PharmaPalette extends ThemeExtension<PharmaPalette> {
  const PharmaPalette({
    required this.primaryLight,
    required this.onPrimaryLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.background,
    required this.surface,
    required this.border,
    required this.placeholderBackground,
    required this.placeholderIcon,
  });

  final Color primaryLight;
  final Color onPrimaryLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color background;
  final Color surface;
  final Color border;
  final Color placeholderBackground;
  final Color placeholderIcon;

  static const light = PharmaPalette(
    primaryLight: Color(0xFFE0F2F1),
    onPrimaryLight: Color(0xFF005C5A),
    textPrimary: Color(0xFF1E293B),
    textSecondary: Color(0xFF64748B),
    textHint: Color(0xFF94A3B8),
    background: Color(0xFFF8FAFC),
    surface: Colors.white,
    border: Color(0xFFE8EDF2),
    placeholderBackground: Color(0xFFF1F5F9),
    placeholderIcon: Color(0xFFCBD5E1),
  );

  static const dark = PharmaPalette(
    primaryLight: Color(0xFF15313A),
    onPrimaryLight: Color(0xFFBFECEA),
    textPrimary: Color(0xFFE8EDF5),
    textSecondary: Color(0xFF9FACBD),
    textHint: Color(0xFF66707F),
    background: Color(0xFF0E1319),
    surface: Color(0xFF161D26),
    border: Color(0xFF273040),
    placeholderBackground: Color(0xFF202936),
    placeholderIcon: Color(0xFF4A5566),
  );

  @override
  PharmaPalette copyWith({
    Color? primaryLight,
    Color? onPrimaryLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? background,
    Color? surface,
    Color? border,
    Color? placeholderBackground,
    Color? placeholderIcon,
  }) {
    return PharmaPalette(
      primaryLight: primaryLight ?? this.primaryLight,
      onPrimaryLight: onPrimaryLight ?? this.onPrimaryLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      placeholderBackground: placeholderBackground ?? this.placeholderBackground,
      placeholderIcon: placeholderIcon ?? this.placeholderIcon,
    );
  }

  @override
  PharmaPalette lerp(ThemeExtension<PharmaPalette>? other, double t) {
    if (other is! PharmaPalette) return this;
    return PharmaPalette(
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      onPrimaryLight: Color.lerp(onPrimaryLight, other.onPrimaryLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      placeholderBackground:
          Color.lerp(placeholderBackground, other.placeholderBackground, t)!,
      placeholderIcon: Color.lerp(placeholderIcon, other.placeholderIcon, t)!,
    );
  }
}