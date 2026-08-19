import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/focus_session.dart';
import '../../providers/focus_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../../widgets/tree_widget.dart';

class ForestScreen extends StatelessWidget {
  const ForestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();
    final shop = context.watch<ShopProvider>();
    final stats = focus.stats;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return AppPageScaffold(
      title: AppStrings.t(context, 'forestTitle'),
      subtitle: AppStrings.t(context, 'forestSubtitle'),
      actions: [
        CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
      ],
      children: [
        AppGlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(AppStrings.t(context, 'dailyGoal'), style: AppTypography.labelBold(size: 13)),
                  const Spacer(),
                  Text(
                    AppStrings.t(context, 'goalProgress', {
                      'done': '${stats.todayMinutes}',
                      'goal': '${focus.dailyGoalMinutes}',
                    }),
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: focus.dailyGoalProgress,
                  minHeight: 8,
                  backgroundColor: primary.withValues(alpha: 0.12),
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.45,
          children: [
            _StatTile(icon: Icons.park_outlined, label: AppStrings.t(context, 'statTrees'), value: '${stats.treesGrown}', color: primary),
            _StatTile(icon: Icons.local_fire_department_outlined, label: AppStrings.t(context, 'statStreak'), value: AppStrings.t(context, 'daysValue', {'count': '${stats.currentStreak}'}), color: AppColors.warning),
            _StatTile(icon: Icons.calendar_view_week_outlined, label: AppStrings.t(context, 'statWeek'), value: AppStrings.t(context, 'minutesValue', {'count': '${stats.weekMinutes}'}), color: AppColors.breakColor),
            _StatTile(icon: Icons.emoji_events_outlined, label: AppStrings.t(context, 'statBestDay'), value: AppStrings.t(context, 'minutesValue', {'count': '${stats.bestDayMinutes}'}), color: AppColors.coin),
          ],
        ),
        const SizedBox(height: 18),
        Text(AppStrings.t(context, 'weekActivity'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 10),
        _WeekHeatmap(days: focus.last7Days),
        const SizedBox(height: 18),
        Text(AppStrings.t(context, 'myGrove'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 10),
        AppGlassCard(
          padding: const EdgeInsets.all(14),
          child: focus.sessions.where((s) => s.completed).isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    AppStrings.t(context, 'noSessionsYet'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.onSurfaceVariant, height: 1.4),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: focus.sessions.where((s) => s.completed).take(16).map((s) {
                    final p = ((s.durationSeconds / 60) / 60).clamp(0.45, 1.0);
                    return SizedBox(
                      width: 52,
                      height: 58,
                      child: TreeWidget(progress: p, style: shop.activeTreeStyle, size: 48),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 18),
        Text(AppStrings.t(context, 'achievements'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 10),
        ...focus.achievements.map((a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (a.unlocked ? AppColors.coin : AppColors.onSurfaceVariant).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        a.unlocked ? Icons.emoji_events_rounded : Icons.lock_outline,
                        color: a.unlocked ? AppColors.coin : AppColors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.t(context, a.titleKey), style: AppTypography.labelBold(size: 14)),
                          Text(
                            AppStrings.t(context, a.descKey),
                            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    if (!a.unlocked)
                      Text(AppStrings.t(context, 'achLocked'), style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 10),
        Text(AppStrings.t(context, 'recentSessions'), style: AppTypography.labelBold(size: 14)),
        const SizedBox(height: 10),
        if (focus.sessions.isEmpty)
          AppGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Text(
              AppStrings.t(context, 'noSessionsYet'),
              style: const TextStyle(color: AppColors.onSurfaceVariant, height: 1.4),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...focus.sessions.take(20).map((session) {
            final mins = (session.durationSeconds / 60).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.eco_outlined, color: primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.t(context, FocusTag.labelKey(session.tag)),
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
                      style: AppTypography.labelBold(size: 14, color: primary),
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

class _WeekHeatmap extends StatelessWidget {
  final List<DayMinutes> days;

  const _WeekHeatmap({required this.days});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final maxMins = days.fold<int>(1, (m, d) => d.minutes > m ? d.minutes : m);
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const labelsEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final isVi = Localizations.maybeLocaleOf(context)?.languageCode == 'vi' ||
        AppStrings.languageCodeOf(context) == 'vi';

    return AppGlassCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: Column(
                children: [
                  Text(
                    isVi ? labels[days[i].day.weekday - 1] : labelsEn[days[i].day.weekday - 1],
                    style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 42,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08 + 0.72 * (days[i].minutes / maxMins)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${days[i].minutes}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: days[i].minutes == 0 ? AppColors.onSurfaceVariant : AppColors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: AppTypography.titleLarge().copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
