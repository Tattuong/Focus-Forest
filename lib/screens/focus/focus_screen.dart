import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/focus_session.dart';
import '../../providers/focus_provider.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/ad_banner_placeholder.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_purchase_sheet.dart';
import '../../widgets/tree_widget.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPageScaffold(
      title: AppStrings.t(context, 'focusTitle'),
      subtitle: _phaseLabel(context, focus.phase),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
        ),
      ],
      children: [
        const SizedBox(height: 8),
        Center(
          child: AppGlassCard(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              children: [
                TreeWidget(
                  progress: focus.isRunning || focus.isPaused ? focus.progress : (focus.isCompleted ? 1 : 0.08),
                  style: shop.activeTreeStyle,
                  size: 200,
                ),
                const SizedBox(height: 20),
                Text(
                  focus.formattedTime,
                  style: AppTypography.displayLarge(
                    color: isDark ? Colors.white : AppColors.onSurface,
                  ).copyWith(fontSize: 56, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  _stateLabel(context, focus),
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                ),
                if (shop.hasCustomTimer && focus.phase == TimerPhase.focus && focus.isIdle) ...[
                  const SizedBox(height: 16),
                  _DurationPicker(focus: focus),
                ],
                if (focus.phase == TimerPhase.focus && !focus.sessionQualifiesForReward) ...[
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.t(context, 'starRewardHint'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ],
                if (shop.hasWhiteNoise && focus.phase == TimerPhase.focus) ...[
                  const SizedBox(height: 12),
                  FilterChip(
                    selected: focus.whiteNoiseEnabled,
                    onSelected: (_) => focus.toggleWhiteNoise(),
                    avatar: Icon(
                      focus.whiteNoiseEnabled ? Icons.graphic_eq : Icons.graphic_eq_outlined,
                      size: 18,
                    ),
                    label: Text(AppStrings.t(context, 'whiteNoise')),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (focus.isRunning || focus.isPaused)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: focus.stop,
                  icon: const Icon(Icons.stop_rounded),
                  label: Text(AppStrings.t(context, 'stop')),
                ),
              ),
            if (focus.isRunning || focus.isPaused) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () {
                  if (focus.isRunning) {
                    focus.pause();
                  } else if (focus.isPaused) {
                    focus.resume();
                  } else if (focus.isCompleted && focus.phase != TimerPhase.focus) {
                    focus.skipBreak();
                  } else {
                    focus.start();
                  }
                },
                icon: Icon(
                  focus.isRunning
                      ? Icons.pause_rounded
                      : focus.isCompleted && focus.phase != TimerPhase.focus
                          ? Icons.skip_next_rounded
                          : Icons.play_arrow_rounded,
                ),
                label: Text(_primaryButtonLabel(context, focus)),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppGlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _MiniStat(icon: Icons.local_florist_outlined, label: AppStrings.t(context, 'statTrees'), value: '${focus.stats.treesGrown}'),
              _divider(isDark),
              _MiniStat(icon: Icons.timer_outlined, label: AppStrings.t(context, 'statTodayTime'), value: '${focus.stats.todayMinutes}m'),
              _divider(isDark),
              _MiniStat(icon: Icons.local_fire_department_outlined, label: AppStrings.t(context, 'statStreak'), value: '${focus.stats.currentStreak}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(bool isDark) => Container(
        width: 1,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.12),
      );

  String _phaseLabel(BuildContext context, TimerPhase phase) => switch (phase) {
        TimerPhase.focus => AppStrings.t(context, 'phaseFocus'),
        TimerPhase.shortBreak => AppStrings.t(context, 'phaseShortBreak'),
        TimerPhase.longBreak => AppStrings.t(context, 'phaseLongBreak'),
      };

  String _stateLabel(BuildContext context, FocusProvider focus) {
    if (focus.isRunning) return AppStrings.t(context, 'timerRunning');
    if (focus.isPaused) return AppStrings.t(context, 'timerPaused');
    if (focus.isCompleted) return AppStrings.t(context, 'timerCompleted');
    return AppStrings.t(context, 'timerReady');
  }

  String _primaryButtonLabel(BuildContext context, FocusProvider focus) {
    if (focus.isRunning) return AppStrings.t(context, 'pause');
    if (focus.isPaused) return AppStrings.t(context, 'resume');
    if (focus.isCompleted && focus.phase != TimerPhase.focus) return AppStrings.t(context, 'skipBreak');
    return AppStrings.t(context, 'startFocus');
  }
}

class _DurationPicker extends StatelessWidget {
  final FocusProvider focus;

  const _DurationPicker({required this.focus});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: focus.availableDurations.map((mins) {
        final selected = focus.focusDurationMinutes == mins;
        return ChoiceChip(
          selected: selected,
          label: Text('${mins}m'),
          onSelected: (_) => focus.setFocusDuration(mins),
        );
      }).toList(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.labelBold(size: 16)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
