import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/focus_provider.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';

class ForestScreen extends StatelessWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();
    final stats = focus.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPageScaffold(
      title: AppStrings.t(context, 'forestTitle'),
      subtitle: AppStrings.t(context, 'forestSubtitle'),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        AppGlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t(context, 'statsOverview'), style: AppTypography.titleLarge()),
              const SizedBox(height: 16),
              _StatRow(
                icon: Icons.access_time_filled,
                label: AppStrings.t(context, 'statTotalTime'),
                value: AppStrings.t(context, 'minutesValue', {'count': '${stats.totalMinutes}'}),
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.today_outlined,
                label: AppStrings.t(context, 'statTodayTime'),
                value: AppStrings.t(context, 'minutesValue', {'count': '${stats.todayMinutes}'}),
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.check_circle_outline,
                label: AppStrings.t(context, 'statTotalSessions'),
                value: '${stats.totalSessions}',
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.local_florist_outlined,
                label: AppStrings.t(context, 'statTrees'),
                value: '${stats.treesGrown}',
              ),
              const SizedBox(height: 12),
              _StatRow(
                icon: Icons.local_fire_department_outlined,
                label: AppStrings.t(context, 'statStreak'),
                value: AppStrings.t(context, 'daysValue', {'count': '${stats.currentStreak}'}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(AppStrings.t(context, 'recentSessions'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 8),
        if (focus.sessions.isEmpty)
          AppGlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.forest_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.t(context, 'noSessionsYet'),
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...focus.sessions.take(20).map((session) {
            final mins = (session.durationSeconds / 60).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.eco_outlined, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.t(context, 'sessionCompleted'),
                            style: AppTypography.labelBold(size: 14),
                          ),
                          Text(
                            AppStrings.formatDate(session.completedAt),
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppStrings.t(context, 'minutesValue', {'count': '$mins'}),
                      style: AppTypography.labelBold(size: 14, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant))),
        Text(value, style: AppTypography.labelBold(size: 15)),
      ],
    );
  }
}
