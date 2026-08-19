import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/shop_provider.dart';
import 'coin_purchase_sheet.dart';

class CoinBalanceChip extends StatelessWidget {
  final VoidCallback? onTap;

  const CoinBalanceChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => CoinPurchaseSheet.show(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
          decoration: BoxDecoration(
            color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.coin.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: AppColors.coin, size: 16),
              const SizedBox(width: 5),
              Text(
                '${shop.coins}',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.onSurface),
              ),
              if (!shop.isBillingDisabled) ...[
                const SizedBox(width: 2),
                Icon(Icons.add, color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
