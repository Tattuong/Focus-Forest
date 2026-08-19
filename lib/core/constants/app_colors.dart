import 'package:flutter/material.dart';

/// Focus Forest — warm paper, forest green, quiet gold.
class AppColors {
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryDark = Color(0xFF1B4332);

  static const Color accent = Color(0xFF40916C);
  static const Color accentAlt = Color(0xFF95D5B2);

  static const Color background = Color(0xFFF6F3EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEE8DE);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1D2A24);
  static const Color onSurfaceVariant = Color(0xFF6B746F);

  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color coin = Color(0xFFE0A100);

  static const Color darkBackground = Color(0xFF121A16);
  static const Color darkSurface = Color(0xFF1C2A22);

  static const Color focus = Color(0xFF2D6A4F);
  static const Color breakColor = Color(0xFF3A7CA5);
  static const Color tree = Color(0xFF1B4332);
  static const Color soil = Color(0xFF8B5E34);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF52B788)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF74C69D)],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D6A4F), Color(0xFFE0A100)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121A16), Color(0xFF1B4332), Color(0xFF2D6A4F)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF6F3EE)],
  );

  static const List<Color> categoryPalette = [
    Color(0xFF2D6A4F),
    Color(0xFF40916C),
    Color(0xFF3A7CA5),
    Color(0xFFE0A100),
    Color(0xFF95D5B2),
    Color(0xFF1B4332),
    Color(0xFF52B788),
    Color(0xFF6B746F),
  ];
}
