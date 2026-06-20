import 'package:flutter/material.dart';

enum ShopItemType {
  theme,
  background,
  skin,
  feature,
  removeAds,
}

enum ShopItemCategory {
  themes,
  backgrounds,
  skins,
  features,
  premium,
}

class ShopItem {
  final String id;
  final String nameKey;
  final String descKey;
  final int price;
  final ShopItemType type;
  final ShopItemCategory category;
  final IconData icon;
  final bool oneTime;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.price,
    required this.type,
    required this.category,
    required this.icon,
    this.oneTime = true,
  });
}

class ShopCatalog {
  ShopCatalog._();

  static const String defaultThemeId = 'theme_default';
  static const String defaultBackgroundId = 'bg_default';
  static const String defaultSkinId = 'skin_default';

  static const List<ShopItem> items = [
    ShopItem(
      id: 'remove_ads',
      nameKey: 'shopRemoveAds',
      descKey: 'shopRemoveAdsDesc',
      price: 500,
      type: ShopItemType.removeAds,
      category: ShopItemCategory.premium,
      icon: Icons.block_outlined,
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'shopThemeSunset',
      descKey: 'shopThemeSunsetDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.wb_twilight_outlined,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'shopThemeOcean',
      descKey: 'shopThemeOceanDesc',
      price: 200,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.water_outlined,
    ),
    ShopItem(
      id: 'theme_aurora',
      nameKey: 'shopThemeAurora',
      descKey: 'shopThemeAuroraDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.auto_awesome_outlined,
    ),
    ShopItem(
      id: 'theme_cherry',
      nameKey: 'shopThemeCherry',
      descKey: 'shopThemeCherryDesc',
      price: 250,
      type: ShopItemType.theme,
      category: ShopItemCategory.themes,
      icon: Icons.local_florist_outlined,
    ),
    ShopItem(
      id: 'bg_meadow',
      nameKey: 'shopBgMeadow',
      descKey: 'shopBgMeadowDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.grass_outlined,
    ),
    ShopItem(
      id: 'bg_sunset',
      nameKey: 'shopBgSunset',
      descKey: 'shopBgSunsetDesc',
      price: 150,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.wb_sunny_outlined,
    ),
    ShopItem(
      id: 'bg_night',
      nameKey: 'shopBgNight',
      descKey: 'shopBgNightDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.nightlight_outlined,
    ),
    ShopItem(
      id: 'bg_spring',
      nameKey: 'shopBgSpring',
      descKey: 'shopBgSpringDesc',
      price: 200,
      type: ShopItemType.background,
      category: ShopItemCategory.backgrounds,
      icon: Icons.spa_outlined,
    ),
    ShopItem(
      id: 'skin_oak',
      nameKey: 'shopSkinOak',
      descKey: 'shopSkinOakDesc',
      price: 200,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.park_outlined,
    ),
    ShopItem(
      id: 'skin_pine',
      nameKey: 'shopSkinPine',
      descKey: 'shopSkinPineDesc',
      price: 150,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.forest_outlined,
    ),
    ShopItem(
      id: 'skin_sakura',
      nameKey: 'shopSkinSakura',
      descKey: 'shopSkinSakuraDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.filter_vintage_outlined,
    ),
    ShopItem(
      id: 'skin_bamboo',
      nameKey: 'shopSkinBamboo',
      descKey: 'shopSkinBambooDesc',
      price: 180,
      type: ShopItemType.skin,
      category: ShopItemCategory.skins,
      icon: Icons.eco_outlined,
    ),
    ShopItem(
      id: 'feat_custom_timer',
      nameKey: 'shopFeatCustomTimer',
      descKey: 'shopFeatCustomTimerDesc',
      price: 300,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.timer_outlined,
    ),
    ShopItem(
      id: 'feat_long_break',
      nameKey: 'shopFeatLongBreak',
      descKey: 'shopFeatLongBreakDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.free_breakfast_outlined,
    ),
    ShopItem(
      id: 'feat_white_noise',
      nameKey: 'shopFeatWhiteNoise',
      descKey: 'shopFeatWhiteNoiseDesc',
      price: 250,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.graphic_eq_outlined,
    ),
    ShopItem(
      id: 'feat_stats_export',
      nameKey: 'shopFeatStatsExport',
      descKey: 'shopFeatStatsExportDesc',
      price: 200,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.file_download_outlined,
    ),
    ShopItem(
      id: 'feat_no_watermark',
      nameKey: 'shopFeatNoWatermark',
      descKey: 'shopFeatNoWatermarkDesc',
      price: 150,
      type: ShopItemType.feature,
      category: ShopItemCategory.features,
      icon: Icons.image_not_supported_outlined,
    ),
  ];

  static ShopItem? find(String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
}
