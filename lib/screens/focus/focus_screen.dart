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

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  static const _kNavClearance = 88.0;

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final treeProgress = focus.isRunning || focus.isPaused
        ? focus.progress
        : (focus.isCompleted && focus.phase == TimerPhase.focus ? 1.0 : 0.06);
    final ringProgress = focus.phase == TimerPhase.focus
        ? ((focus.isRunning || focus.isPaused) ? focus.progress : 0.0)
        : 0.0;
    final phaseColor = _phaseColor(focus.phase, primary);

    return AppPageScaffold(
      fitContent: true,
      bottomInset: _kNavClearance,
      title: AppStrings.t(context, 'focusTitle'),
      subtitle: _phaseLabel(context, focus.phase),
      actions: [
        CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
      ],
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final ringSize = (box.maxWidth * 0.72).clamp(150.0, 200.0);
              final treeSize = ringSize * 0.42;
              final timerSize = (ringSize * 0.19).clamp(28.0, 38.0);

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark ? AppColors.darkSurface.withValues(alpha: 0.92) : Colors.white,
                  border: Border.all(color: primary.withValues(alpha: isDark ? 0.15 : 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(end: treeProgress),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (_, animatedTree, __) {
                            return FocusProgressRing(
                              progress: ringProgress,
                              color: phaseColor,
                              size: ringSize,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TreeWidget(
                                    progress: animatedTree,
                                    style: shop.activeTreeStyle,
                                    size: treeSize,
                                  ),
                                  SizedBox(height: ringSize * 0.02),
                                  Text(
                                    focus.formattedTime,
                                    style: AppTypography.displayLarge(
                                      color: isDark ? Colors.white : AppColors.onSurface,
                                    ).copyWith(
                                      fontSize: timerSize,
                                      letterSpacing: 1,
                                      height: 1,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _stateLabel(context, focus),
                                    style: TextStyle(
                                      color: phaseColor.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (focus.phase == TimerPhase.focus && (focus.isRunning || focus.isPaused))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: focus.progress,
                            minHeight: 4,
                            backgroundColor: primary.withValues(alpha: 0.1),
                            color: primary,
                          ),
                        ),
                      ),
                    if (shop.hasCustomTimer && focus.phase == TimerPhase.focus && focus.isIdle)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: _DurationPicker(focus: focus),
                      ),
                    if (focus.phase == TimerPhase.focus && !focus.sessionQualifiesForReward)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: _HintBanner(text: AppStrings.t(context, 'starRewardHint')),
                      ),
                    if (shop.hasWhiteNoise && focus.phase == TimerPhase.focus)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FilterChip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          selected: focus.whiteNoiseEnabled,
                          onSelected: (_) => focus.toggleWhiteNoise(),
                          label: Text(AppStrings.t(context, 'whiteNoise'), style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _ActionButtons(focus: focus),
        const SizedBox(height: 10),
        _StatsBar(focus: focus, isDark: isDark),
      ],
    );
  }

  Color _phaseColor(TimerPhase phase, Color primary) => switch (phase) {
        TimerPhase.focus => primary,
        TimerPhase.shortBreak => AppColors.breakColor,
        TimerPhase.longBreak => const Color(0xFF6366F1),
      };

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
}

class _ActionButtons extends StatelessWidget {
  final FocusProvider focus;

  const _ActionButtons({required this.focus});

  @override
  Widget build(BuildContext context) {
    final showStop = focus.isRunning || focus.isPaused;

    return Row(
      children: [
        if (showStop) ...[
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: focus.stop,
                icon: const Icon(Icons.stop_rounded, size: 18),
                label: Text(AppStrings.t(context, 'stop')),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          flex: showStop ? 2 : 1,
          child: SizedBox(
            height: 48,
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
                size: 20,
              ),
              label: Text(_label(context, focus)),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _label(BuildContext context, FocusProvider focus) {
    if (focus.isRunning) return AppStrings.t(context, 'pause');
    if (focus.isPaused) return AppStrings.t(context, 'resume');
    if (focus.isCompleted && focus.phase != TimerPhase.focus) {
      return AppStrings.t(context, 'skipBreak');
    }
    return AppStrings.t(context, 'startFocus');
  }
}

class _StatsBar extends StatelessWidget {
  final FocusProvider focus;
  final bool isDark;

  const _StatsBar({required this.focus, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AppGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.local_florist_outlined,
            value: '${focus.stats.treesGrown}',
            label: AppStrings.t(context, 'statTrees'),
            color: AppColors.primary,
          ),
          _vDivider(isDark),
          _StatItem(
            icon: Icons.timer_outlined,
            value: '${focus.stats.todayMinutes}m',
            label: AppStrings.t(context, 'statTodayTime'),
            color: AppColors.breakColor,
          ),
          _vDivider(isDark),
          _StatItem(
            icon: Icons.local_fire_department_outlined,
            value: '${focus.stats.currentStreak}',
            label: AppStrings.t(context, 'statStreak'),
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _vDivider(bool isDark) => Container(
        width: 1,
        height: 28,
        color: (isDark ? Colors.white : AppColors.primary).withValues(alpha: 0.1),
      );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppTypography.labelBold(size: 13)),
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HintBanner extends StatelessWidget {
  final String text;

  const _HintBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: AppColors.warning.withValues(alpha: 0.95), height: 1.25),
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final FocusProvider focus;

  const _DurationPicker({required this.focus});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: focus.availableDurations.map((mins) {
        return ChoiceChip(
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          selected: focus.focusDurationMinutes == mins,
          label: Text('${mins}m', style: const TextStyle(fontSize: 11)),
          onSelected: (_) => focus.setFocusDuration(mins),
        );
      }).toList(),
    );
  }
}
