import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/app_theme_preset.dart';
import '../providers/shop_provider.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = brightness == Brightness.dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    return GoogleFonts.plusJakartaSansTextTheme(base);
  }

  static TextStyle displayLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1, color: color);

  static TextStyle titleLarge({Color? color}) =>
      GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: color);

  static TextStyle labelBold({Color? color, double size = 12}) =>
      GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: FontWeight.w700, color: color);
}

class AppDecorations {
  static const double radiusCard = 18;
  static const double radiusButton = 14;
  static const double radiusChip = 12;

  static BoxDecoration glassCard({
    required bool isDark,
    double radius = radiusCard,
    CardStyle? skin,
    Color? tint,
    Color? surface,
  }) {
    final style = skin ?? CardStyle.defaultStyle;
    final accent = tint ?? style.accentColor;
    final cardSurface = surface ?? (isDark ? AppColors.darkSurface : Colors.white);
    final effectiveRadius = style.borderRadius > 0 ? style.borderRadius : radius;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(effectiveRadius),
      color: cardSurface.withValues(alpha: style.glassEffect ? (isDark ? 0.82 : 0.88) : (isDark ? 0.96 : 1)),
      border: Border.all(
        color: style.borderWidth > 0
            ? style.borderColor.withValues(alpha: isDark ? 0.5 : 0.7)
            : (isDark ? Colors.white : const Color(0xFF1D2A24)).withValues(alpha: isDark ? 0.08 : 0.06),
        width: style.borderWidth > 0 ? style.borderWidth : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.06 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static Widget meshBackground({
    required bool isDark,
    required Widget child,
    LinearGradient? backgroundGradient,
    Color? backgroundColor,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backgroundGradient != null)
          DecoratedBox(decoration: BoxDecoration(gradient: backgroundGradient))
        else
          ColoredBox(color: backgroundColor ?? (isDark ? AppColors.darkBackground : AppColors.background)),
        child,
      ],
    );
  }
}

/// Standard page shell — mesh background, header row, scrollable body.
class AppPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final List<Widget> children;
  final Widget? floatingActionButton;
  final bool fitContent;
  final double bottomInset;
  final bool showLogo;
  final Widget? titleTrailing;

  const AppPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required this.children,
    this.floatingActionButton,
    this.fitContent = false,
    this.bottomInset = 16,
    this.showLogo = false,
    this.titleTrailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shop = context.watch<ShopProvider>();
    final preset = shop.activeTheme;
    final bg = shop.activeBackground;
    final useShopBg = shop.activeBackgroundId != 'bg_default';
    final titleColor = isDark ? Colors.white : AppColors.onSurface;

    return Scaffold(
      backgroundColor: isDark ? preset.darkBackground : preset.background,
      floatingActionButton: floatingActionButton,
      body: AppDecorations.meshBackground(
        isDark: isDark,
        backgroundGradient: useShopBg ? bg.gradient : null,
        backgroundColor: isDark ? preset.darkBackground : preset.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20, fitContent ? 10 : 14, 16, fitContent ? 8 : 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (showLogo) ...[
                      Image.asset('assets/logo.png', width: 32, height: 32, fit: BoxFit.cover),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: AppTypography.titleLarge(color: titleColor).copyWith(
                                    fontSize: 22,
                                    letterSpacing: -0.6,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (titleTrailing != null) titleTrailing!,
                            ],
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle!,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                  ],
                ),
              ),
              Expanded(
                child: fitContent
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, bottomInset),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: children,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool compact;

  const AppScreenHeader({super.key, required this.title, required this.subtitle, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 12 : 0, compact ? 0 : 0, 16, compact ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleLarge()),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.35)),
          ],
        ],
      ),
    );
  }
}

class AppSectionHeader extends StatelessWidget {
  final String label;
  final IconData? icon;

  const AppSectionHeader(this.label, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8, left: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
          ],
          Text(label, style: AppTypography.labelBold(color: AppColors.onSurfaceVariant, size: 13)),
        ],
      ),
    );
  }
}

class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double radius;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skin = context.watch<ShopProvider>().activeCardStyle;
    final effectiveRadius = skin.borderRadius > 0 ? skin.borderRadius : radius;
    final box = Container(
      padding: padding,
      decoration: AppDecorations.glassCard(
        isDark: isDark,
        radius: effectiveRadius,
        skin: skin,
        tint: Theme.of(context).colorScheme.primary,
        surface: Theme.of(context).colorScheme.surface,
      ),
      child: skin.glassEffect
          ? ClipRRect(
              borderRadius: BorderRadius.circular(effectiveRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: child,
              ),
            )
          : child,
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(effectiveRadius), child: box),
    );
  }
}

class AppSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool wrapped;

  const AppSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.wrapped = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;
    final tile = ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: AppTypography.labelBold(size: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)) : null),
    );
    if (!wrapped) return tile;
    return AppGlassCard(padding: EdgeInsets.zero, radius: 16, child: tile);
  }
}

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? primary : AppColors.onSurfaceVariant.withValues(alpha: 0.25)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class AppFormScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback onSave;
  final String saveLabel;
  final List<Widget>? appBarActions;

  const AppFormScreen({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    required this.saveLabel,
    this.appBarActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shop = context.watch<ShopProvider>();
    final useShopBg = shop.activeBackgroundId != 'bg_default';

    return Scaffold(
      body: AppDecorations.meshBackground(
        isDark: isDark,
        backgroundGradient: useShopBg ? shop.activeBackground.gradient : null,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    ),
                    Expanded(child: Text(title, style: AppTypography.titleLarge())),
                    if (appBarActions != null) ...appBarActions!,
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    AppGlassCard(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(onPressed: onSave, child: Text(saveLabel)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
