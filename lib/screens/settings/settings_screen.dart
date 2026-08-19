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
        CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
      ],
      children: [
        AppSectionHeader(AppStrings.t(context, 'activeCustomization'), icon: Icons.palette_outlined),
        AppGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingTile(
                wrapped: false,
                icon: Icons.palette_outlined,
                title: AppStrings.t(context, 'activeTheme'),
                subtitle: AppStrings.t(context, _themeNameKey(shop.activeThemeId)),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.layers_outlined,
                title: AppStrings.t(context, 'activeBackground'),
                subtitle: AppStrings.t(context, _bgNameKey(shop.activeBackgroundId)),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.park_outlined,
                title: AppStrings.t(context, 'activeSkin'),
                subtitle: AppStrings.t(context, _skinNameKey(shop.activeSkinId)),
              ),
            ],
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'timerSettings'), icon: Icons.timer_outlined),
        AppGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingTile(
                wrapped: false,
                icon: Icons.hourglass_bottom_outlined,
                title: AppStrings.t(context, 'focusLength'),
                subtitle: AppStrings.t(context, 'minutesValue', {'count': '${focus.focusDurationMinutes}'}),
                onTap: () => _pickMinutes(context, focus.availableDurations, focus.focusDurationMinutes, focus.setFocusDuration),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.coffee_outlined,
                title: AppStrings.t(context, 'shortBreak'),
                subtitle: AppStrings.t(context, 'minutesValue', {'count': '${focus.shortBreakMinutes}'}),
                onTap: () => _pickMinutes(context, focus.availableShortBreaks, focus.shortBreakMinutes, focus.setShortBreak),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.self_improvement_outlined,
                title: AppStrings.t(context, 'longBreak'),
                subtitle: AppStrings.t(context, 'minutesValue', {'count': '${focus.longBreakMinutes}'}),
                onTap: () => _pickMinutes(context, focus.availableLongBreaks, focus.longBreakMinutes, focus.setLongBreak),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.flag_outlined,
                title: AppStrings.t(context, 'dailyGoalSetting'),
                subtitle: AppStrings.t(context, 'minutesValue', {'count': '${focus.dailyGoalMinutes}'}),
                onTap: () => _pickMinutes(context, focus.availableGoals, focus.dailyGoalMinutes, focus.setDailyGoal),
              ),
            ],
          ),
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            title: Text(AppStrings.t(context, 'darkMode'), style: AppTypography.labelBold(size: 14)),
            value: theme.isDarkMode,
            onChanged: (_) => theme.toggleTheme(),
          ),
        ),
        AppSectionHeader(AppStrings.t(context, 'premiumFeatures'), icon: Icons.workspace_premium_outlined),
        AppGlassCard(
          padding: EdgeInsets.zero,
          child: shop.hasStatsExport
              ? AppSettingTile(
                  wrapped: false,
                  icon: Icons.file_download_outlined,
                  title: AppStrings.t(context, 'exportStats'),
                  subtitle: AppStrings.t(context, 'exportStatsDesc'),
                  trailing: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.primary),
                  onTap: () => _exportStats(context, focus, shop),
                )
              : AppSettingTile(
                  wrapped: false,
                  icon: Icons.file_download_outlined,
                  title: AppStrings.t(context, 'exportStats'),
                  subtitle: AppStrings.t(context, 'exportLocked'),
                  onTap: () => MainShell.of(context)?.openShop(tab: ShopRewardsTab.features),
                ),
        ),
        AppSectionHeader(AppStrings.t(context, 'other'), icon: Icons.more_horiz_rounded),
        AppGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              AppSettingTile(
                wrapped: false,
                icon: Icons.language_outlined,
                title: AppStrings.t(context, 'language'),
                subtitle: locale.isVietnamese ? AppStrings.t(context, 'vietnamese') : AppStrings.t(context, 'english'),
                onTap: () => _pickLanguage(context, locale),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.storefront_outlined,
                title: AppStrings.t(context, 'openShop'),
                subtitle: AppStrings.t(context, 'openShopDesc'),
                iconColor: AppColors.coin,
                onTap: () => MainShell.of(context)?.openShop(),
              ),
              const Divider(height: 1, indent: 72),
              AppSettingTile(
                wrapped: false,
                icon: Icons.privacy_tip_outlined,
                title: AppStrings.t(context, 'privacyPolicy'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
              ),
            ],
          ),
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

  Future<void> _pickMinutes(
    BuildContext context,
    List<int> options,
    int current,
    Future<void> Function(int) onPick,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                for (final m in options)
                  ListTile(
                    title: Text(AppStrings.t(context, 'minutesValue', {'count': '$m'})),
                    trailing: current == m ? Icon(Icons.check_rounded, color: Theme.of(ctx).colorScheme.primary) : null,
                    onTap: () async {
                      await onPick(m);
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
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 22)),
                  title: Text(AppStrings.t(context, 'english')),
                  trailing: !locale.isVietnamese ? Icon(Icons.check_rounded, color: Theme.of(ctx).colorScheme.primary) : null,
                  onTap: () async {
                    await locale.setEnglish();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Text('🇻🇳', style: TextStyle(fontSize: 22)),
                  title: Text(AppStrings.t(context, 'vietnamese')),
                  trailing: locale.isVietnamese ? Icon(Icons.check_rounded, color: Theme.of(ctx).colorScheme.primary) : null,
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
