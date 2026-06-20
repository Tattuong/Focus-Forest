class IapConstants {
  IapConstants._();

  static const String productPrefix = 'ff';

  static const String remoteConfigUrl = 'https://api2.blwsmartware.net/N207.json';

  static const Duration configTimeout = Duration(seconds: 10);

  static const List<String> coinPackIds = [
    'ff_pack_1',
    'ff_pack_2',
    'ff_pack_3',
    'ff_pack_4',
    'ff_pack_5',
    'ff_pack_6',
    'ff_pack_7',
    'ff_pack_8',
    'ff_pack_9',
    'ff_pack_10',
  ];

  static const String removeAdsProductId = 'ff_remove_ads';

  static List<String> get allProductIds => [...coinPackIds, removeAdsProductId];

  static const List<int> coinPackAmounts = [
    50, 100, 200, 350, 500, 750, 1000, 1500, 2200, 3000,
  ];

  static int coinsForProduct(String productId) {
    final index = coinPackIds.indexOf(productId);
    if (index < 0) return 0;
    return coinPackAmounts[index];
  }

  static bool isRemoveAdsProduct(String productId) => productId == removeAdsProductId;

  static const int dailyLoginReward = 10;
  static const int minFocusMinutesForReward = 20;
  static const int focusSessionReward = 5;
  static const int maxFocusRewardsPerDay = 12;
  static const int streakBonusReward = 15;
  static const int maxStreakBonusPerDay = 1;
}
