import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/focus_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../main_shell.dart';
import '../privacy_policy_screen.dart';
import '../shop/shop_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final theme = context.watch<ThemeProvider>();
    final locale = context.watch<LocaleProvider>();
    final focus = context.watch<FocusProvider>();

    return AppPageScaffold(
      title: AppStrings.t(context, 'settingsTitle'),
      subtitle: AppStrings.t(context, 'settingsSubtitle'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        AppSectionHeader(AppStrings.t(context, 'activeCustomization'), icon: Icons.palette_outlined),
        AppSettingTile(
          icon: Icons.palette_outlined,
          title: AppStrings.t(context, 'activeTheme'),
          subtitle: AppStrings.t(context, _themeNameKey(shop.activeThemeId)),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.layers_outlined,
          title: AppStrings.t(context, 'activeBackground'),
          subtitle: AppStrings.t(context, _bgNameKey(shop.activeBackgroundId)),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.park_outlined,
          title: AppStrings.t(context, 'activeSkin'),
          subtitle: AppStrings.t(context, _skinNameKey(shop.activeSkinId)),
        ),
        AppSectionHeader(AppStrings.t(context, 'appearance'), icon: Icons.dark_mode_outlined),
        AppGlassCard(
          padding: EdgeInsets.zero,
          child: SwitchListTile(
            secondary: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.dark_mode_outlined, color: AppColors.primary, size: 20),
            ),
            title: Text(AppStrings.t(context, 'darkMode'), style: AppTypography.labelBold(size: 14)),
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'premiumFeatures'), icon: Icons.workspace_premium_outlined),
        if (shop.hasStatsExport) ...[
          AppSettingTile(
            icon: Icons.file_download_outlined,
            title: AppStrings.t(context, 'exportStats'),
            subtitle: AppStrings.t(context, 'exportStatsDesc'),
            trailing: const Icon(Icons.share_outlined, color: AppColors.primary),
            onTap: () => _exportStats(context, focus, shop),
          ),
          const SizedBox(height: 8),
        ] else
          AppSettingTile(
            icon: Icons.file_download_outlined,
            title: AppStrings.t(context, 'exportStats'),
            subtitle: AppStrings.t(context, 'exportLocked'),
            onTap: () => MainShell.of(context)?.openShop(tab: ShopRewardsTab.features),
          ),
        AppSectionHeader(AppStrings.t(context, 'other'), icon: Icons.more_horiz_rounded),
        AppSettingTile(
          icon: Icons.language_outlined,
          title: AppStrings.t(context, 'language'),
          subtitle: locale.isVietnamese ? AppStrings.t(context, 'vietnamese') : AppStrings.t(context, 'english'),
          onTap: () => _pickLanguage(context, locale),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.stars_rounded,
          title: AppStrings.t(context, 'openShop'),
          subtitle: AppStrings.t(context, 'openShopDesc'),
          iconColor: AppColors.coin,
          onTap: () => MainShell.of(context)?.openShop(),
        ),
        const SizedBox(height: 8),
        AppSettingTile(
          icon: Icons.privacy_tip_outlined,
          title: AppStrings.t(context, 'privacyPolicy'),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            AppStrings.t(context, 'copyright'),
            style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _exportStats(BuildContext context, FocusProvider focus, ShopProvider shop) async {
    final text = focus.exportStats(
      (key) => AppStrings.t(context, key),
      includeWatermark: !shop.hasNoWatermark,
    );
    await Share.share(text);
    if (context.mounted) AppToast.show(context, title: AppStrings.t(context, 'exportDone'));
  }

  Future<void> _pickLanguage(BuildContext context, LocaleProvider locale) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                  title: Text(AppStrings.t(context, 'english')),
                  trailing: !locale.isVietnamese ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () async {
                    await locale.setEnglish();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇻🇳', style: TextStyle(fontSize: 22)),
                  title: Text(AppStrings.t(context, 'vietnamese')),
                  trailing: locale.isVietnamese ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
                  onTap: () async {
                    await locale.setVietnamese();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _themeNameKey(String id) => switch (id) {
        'theme_sunset' => 'shopThemeSunset',
        'theme_ocean' => 'shopThemeOcean',
        'theme_aurora' => 'shopThemeAurora',
        'theme_cherry' => 'shopThemeCherry',
        _ => 'themeDefault',
      };

  String _bgNameKey(String id) => switch (id) {
        'bg_meadow' => 'shopBgMeadow',
        'bg_sunset' => 'shopBgSunset',
        'bg_night' => 'shopBgNight',
        'bg_spring' => 'shopBgSpring',
        _ => 'bgDefault',
      };

  String _skinNameKey(String id) => switch (id) {
        'skin_oak' => 'shopSkinOak',
        'skin_pine' => 'shopSkinPine',
        'skin_sakura' => 'shopSkinSakura',
        'skin_bamboo' => 'shopSkinBamboo',
        _ => 'skinDefault',
      };
}
