import 'package:flutter/material.dart';

/// Focus Forest — lush greens, warm gold accents.
class AppColors {
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryDark = Color(0xFF15803D);

  static const Color accent = Color(0xFF22C55E);
  static const Color accentAlt = Color(0xFF86EFAC);

  static const Color background = Color(0xFFF0FDF4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFDCFCE7);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF14532D);
  static const Color onSurfaceVariant = Color(0xFF64748B);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color coin = Color(0xFFFBBF24);

  static const Color darkBackground = Color(0xFF052E16);
  static const Color darkSurface = Color(0xFF14532D);

  static const Color focus = Color(0xFF16A34A);
  static const Color breakColor = Color(0xFF0EA5E9);
  static const Color tree = Color(0xFF166534);
  static const Color soil = Color(0xFF92400E);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF14532D), Color(0xFF16A34A), Color(0xFF4ADE80)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF166534), Color(0xFF22C55E)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16A34A), Color(0xFFFBBF24)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF052E16), Color(0xFF14532D), Color(0xFF16A34A)],
  );

  static const List<Color> categoryPalette = [
    Color(0xFF16A34A),
    Color(0xFF22C55E),
    Color(0xFF0EA5E9),
    Color(0xFFFBBF24),
    Color(0xFF86EFAC),
    Color(0xFF15803D),
    Color(0xFF4ADE80),
    Color(0xFF64748B),
  ];
}
