import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../widgets/app_ui.dart';
import 'focus/focus_screen.dart';
import 'forest/forest_screen.dart';
import 'settings/settings_screen.dart';
import 'shop/shop_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static MainShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainShellState>();

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _index = 0;
  final _shopKey = GlobalKey<ShopScreenState>();

  void openShop({ShopRewardsTab tab = ShopRewardsTab.all}) {
    setState(() => _index = 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _shopKey.currentState?.selectTab(tab);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = [
      const FocusScreen(),
      const ForestScreen(),
      ShopScreen(key: _shopKey, embedded: true),
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _index, children: screens),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                  index: 0,
                  currentIndex: _index,
                  icon: Icons.timer_outlined,
                  activeIcon: Icons.timer_rounded,
                  label: AppStrings.t(context, 'navFocus'),
                  onTap: () => setState(() => _index = 0),
                ),
                _NavItem(
                  index: 1,
                  currentIndex: _index,
                  icon: Icons.park_outlined,
                  activeIcon: Icons.park_rounded,
                  label: AppStrings.t(context, 'navForest'),
                  onTap: () => setState(() => _index = 1),
                ),
                _NavItem(
                  index: 2,
                  currentIndex: _index,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: AppStrings.t(context, 'navShop'),
                  onTap: () => setState(() => _index = 2),
                  accent: AppColors.coin,
                ),
                _NavItem(
                  index: 3,
                  currentIndex: _index,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: AppStrings.t(context, 'navSettings'),
                  onTap: () => setState(() => _index = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final Color? accent;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
    this.accent,
  });

  bool get active => index == currentIndex;

  @override
  Widget build(BuildContext context) {
    final color = active ? (accent ?? Theme.of(context).colorScheme.primary) : AppColors.onSurfaceVariant;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(active ? activeIcon : icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelBold(color: color, size: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
