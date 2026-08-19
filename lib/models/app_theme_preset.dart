import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../widgets/app_ui.dart';

class AppThemePreset {
  final String id;
  final Color primary;
  final Color primaryLight;
  final Color background;
  final Color surface;
  final Color darkBackground;
  final Color darkSurface;
  final LinearGradient headerGradient;
  final LinearGradient balanceGradient;

  const AppThemePreset({
    required this.id,
    required this.primary,
    required this.primaryLight,
    required this.background,
    required this.surface,
    required this.darkBackground,
    required this.darkSurface,
    required this.headerGradient,
    required this.balanceGradient,
  });

  ThemeData lightTheme() => _buildTheme(
        brightness: Brightness.light,
        scaffold: background,
        surfaceColor: surface,
        onSurface: AppColors.onSurface,
      );

  ThemeData darkTheme() => _buildTheme(
        brightness: Brightness.dark,
        scaffold: darkBackground,
        surfaceColor: darkSurface,
        onSurface: const Color(0xFFECFDF5),
      );

  ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffold,
    required Color surfaceColor,
    required Color onSurface,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffold,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryLight,
              secondary: primary,
              tertiary: AppColors.coin,
              surface: surfaceColor,
              onSurface: onSurface,
              onPrimary: AppColors.onPrimary,
              onSurfaceVariant: const Color(0xFFB7C4BC),
              surfaceContainerHighest: Color.lerp(darkBackground, primaryLight, 0.12)!,
            )
          : ColorScheme.light(
              primary: primary,
              secondary: primaryLight,
              tertiary: AppColors.coin,
              surface: surfaceColor,
              onPrimary: AppColors.onPrimary,
              onSurface: onSurface,
              onSurfaceVariant: AppColors.onSurfaceVariant,
              surfaceContainerHighest: Color.lerp(background, primary, 0.08)!,
            ),
      textTheme: AppTypography.textTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.titleLarge(color: onSurface),
        iconTheme: IconThemeData(color: onSurface),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? primaryLight : primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurface : AppColors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? primaryLight : primary,
        linearTrackColor: primary.withValues(alpha: 0.12),
        circularTrackColor: primary.withValues(alpha: 0.12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? primaryLight : primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? primaryLight : primary,
          side: BorderSide(color: primary.withValues(alpha: 0.28)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: primary.withValues(alpha: 0.15)),
      ),
      dividerTheme: DividerThemeData(
        color: primary.withValues(alpha: isDark ? 0.12 : 0.08),
        thickness: 1,
      ),
    );
  }
}

class AppThemePresets {
  AppThemePresets._();

  static const AppThemePreset defaultPreset = AppThemePreset(
    id: 'theme_default',
    primary: AppColors.primary,
    primaryLight: AppColors.primaryLight,
    background: Color(0xFFF6F3EE),
    surface: AppColors.surface,
    darkBackground: AppColors.darkBackground,
    darkSurface: AppColors.darkSurface,
    headerGradient: AppColors.headerGradient,
    balanceGradient: AppColors.heroGradient,
  );

  static const AppThemePreset sunset = AppThemePreset(
    id: 'theme_sunset',
    primary: Color(0xFFEA580C),
    primaryLight: Color(0xFFFB923C),
    background: Color(0xFFFFF7ED),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF431407),
    darkSurface: Color(0xFF7C2D12),
    headerGradient: LinearGradient(colors: [Color(0xFF9A3412), Color(0xFFEA580C), Color(0xFFFB923C)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFEA580C), Color(0xFFFBBF24)]),
  );

  static const AppThemePreset ocean = AppThemePreset(
    id: 'theme_ocean',
    primary: Color(0xFF0284C7),
    primaryLight: Color(0xFF38BDF8),
    background: Color(0xFFF0F9FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF0C1929),
    darkSurface: Color(0xFF1A3050),
    headerGradient: LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF0284C7), Color(0xFF38BDF8)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF14B8A6)]),
  );

  static const AppThemePreset aurora = AppThemePreset(
    id: 'theme_aurora',
    primary: Color(0xFF7C3AED),
    primaryLight: Color(0xFFA78BFA),
    background: Color(0xFFF5F3FF),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF2A1030),
    darkSurface: Color(0xFF451A50),
    headerGradient: LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFF2DD4BF)]),
    balanceGradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)]),
  );

  static const AppThemePreset cherry = AppThemePreset(
    id: 'theme_cherry',
    primary: Color(0xFFDB2777),
    primaryLight: Color(0xFFF472B6),
    background: Color(0xFFFDF2F8),
    surface: Color(0xFFFFFFFF),
    darkBackground: Color(0xFF500724),
    darkSurface: Color(0xFF831843),
    headerGradient: LinearGradient(colors: [Color(0xFFBE185D), Color(0xFFDB2777), Color(0xFFF472B6)]),
    balanceGradient: LinearGradient(colors: [Color(0xFFDB2777), Color(0xFFFBBF24)]),
  );

  static const Map<String, AppThemePreset> byId = {
    'theme_default': defaultPreset,
    'theme_sunset': sunset,
    'theme_ocean': ocean,
    'theme_aurora': aurora,
    'theme_cherry': cherry,
  };

  static AppThemePreset get(String? id) => byId[id] ?? defaultPreset;
}

class AppBackground {
  final String id;
  final LinearGradient gradient;

  const AppBackground({required this.id, required this.gradient});

  static const AppBackground defaultBg = AppBackground(
    id: 'bg_default',
    gradient: AppColors.heroGradient,
  );

  static const AppBackground meadow = AppBackground(
    id: 'bg_meadow',
    gradient: LinearGradient(colors: [Color(0xFF14532D), Color(0xFF16A34A), Color(0xFF86EFAC)]),
  );

  static const AppBackground sunset = AppBackground(
    id: 'bg_sunset',
    gradient: LinearGradient(colors: [Color(0xFF9A3412), Color(0xFFEA580C), Color(0xFFFBBF24)]),
  );

  static const AppBackground night = AppBackground(
    id: 'bg_night',
    gradient: LinearGradient(colors: [Color(0xFF052E16), Color(0xFF14532D), Color(0xFF1E3A5F)]),
  );

  static const AppBackground spring = AppBackground(
    id: 'bg_spring',
    gradient: LinearGradient(colors: [Color(0xFF15803D), Color(0xFF4ADE80), Color(0xFFFDE68A)]),
  );

  static const Map<String, AppBackground> byId = {
    'bg_default': defaultBg,
    'bg_meadow': meadow,
    'bg_sunset': sunset,
    'bg_night': night,
    'bg_spring': spring,
  };

  static AppBackground get(String? id) => byId[id] ?? defaultBg;
}

class TreeStyle {
  final String id;
  final Color trunkColor;
  final Color foliageColor;
  final Color foliageLight;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;

  const TreeStyle({
    required this.id,
    required this.trunkColor,
    required this.foliageColor,
    required this.foliageLight,
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primary,
    this.glassEffect = false,
  });

  TreeStyle copyWith({
    Color? trunkColor,
    Color? foliageColor,
    Color? foliageLight,
    Color? accentColor,
  }) {
    return TreeStyle(
      id: id,
      trunkColor: trunkColor ?? this.trunkColor,
      foliageColor: foliageColor ?? this.foliageColor,
      foliageLight: foliageLight ?? this.foliageLight,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      borderColor: borderColor,
      accentColor: accentColor ?? this.accentColor,
      glassEffect: glassEffect,
    );
  }

  /// Default grove follows the shop theme; other skins keep their own palette.
  TreeStyle themed(ColorScheme scheme) {
    if (id != 'skin_default') return this;
    return copyWith(
      foliageColor: scheme.primary,
      foliageLight: scheme.secondary,
      accentColor: scheme.primary,
    );
  }

  static const TreeStyle defaultStyle = TreeStyle(
    id: 'skin_default',
    trunkColor: AppColors.soil,
    foliageColor: AppColors.tree,
    foliageLight: AppColors.primaryLight,
  );

  static const TreeStyle oak = TreeStyle(
    id: 'skin_oak',
    trunkColor: Color(0xFF78350F),
    foliageColor: Color(0xFF166534),
    foliageLight: Color(0xFF22C55E),
    borderRadius: 22,
    borderWidth: 2,
    borderColor: Color(0xFF22C55E),
    accentColor: Color(0xFF22C55E),
  );

  static const TreeStyle pine = TreeStyle(
    id: 'skin_pine',
    trunkColor: Color(0xFF92400E),
    foliageColor: Color(0xFF14532D),
    foliageLight: Color(0xFF15803D),
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: Color(0xFF15803D),
    accentColor: Color(0xFF15803D),
  );

  static const TreeStyle sakura = TreeStyle(
    id: 'skin_sakura',
    trunkColor: Color(0xFF78716C),
    foliageColor: Color(0xFFDB2777),
    foliageLight: Color(0xFFF472B6),
    borderRadius: 24,
    borderWidth: 1,
    borderColor: Color(0xFFF472B6),
    accentColor: Color(0xFFF472B6),
    glassEffect: true,
  );

  static const TreeStyle bamboo = TreeStyle(
    id: 'skin_bamboo',
    trunkColor: Color(0xFF65A30D),
    foliageColor: Color(0xFF4D7C0F),
    foliageLight: Color(0xFF84CC16),
    borderRadius: 18,
    borderWidth: 2,
    borderColor: Color(0xFF84CC16),
    accentColor: Color(0xFF84CC16),
  );

  static const Map<String, TreeStyle> byId = {
    'skin_default': defaultStyle,
    'skin_oak': oak,
    'skin_pine': pine,
    'skin_sakura': sakura,
    'skin_bamboo': bamboo,
  };

  static TreeStyle get(String? id) => byId[id] ?? defaultStyle;
}

class CardStyle {
  final String id;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;
  final Color accentColor;
  final bool glassEffect;

  const CardStyle({
    required this.id,
    this.borderRadius = 20,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.accentColor = AppColors.primary,
    this.glassEffect = false,
  });

  TreeStyle get treeStyle => TreeStyle.get(id);

  static CardStyle get(String? id) {
    final tree = TreeStyle.get(id);
    return CardStyle(
      id: tree.id,
      borderRadius: tree.borderRadius,
      borderWidth: tree.borderWidth,
      borderColor: tree.borderColor,
      accentColor: tree.accentColor,
      glassEffect: tree.glassEffect,
    );
  }

  static const CardStyle defaultStyle = CardStyle(id: 'skin_default');
}
