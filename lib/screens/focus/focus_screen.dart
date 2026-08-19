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

  @override
  Widget build(BuildContext context) {
    final focus = context.watch<FocusProvider>();
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = isDark ? Colors.white : AppColors.onSurface;

    final treeProgress = focus.isRunning || focus.isPaused
        ? focus.progress
        : (focus.isCompleted && focus.phase == TimerPhase.focus ? 1.0 : 0.78);
    final ringProgress = focus.phase == TimerPhase.focus
        ? ((focus.isRunning || focus.isPaused) ? focus.progress : 0.0)
        : 0.0;
    final phaseColor = _phaseColor(focus.phase, primary);

    return AppPageScaffold(
      fitContent: true,
      bottomInset: 12,
      showLogo: false,
      title: AppStrings.t(context, 'focusTitle'),
      subtitle: _phaseLabel(context, focus.phase),
      titleTrailing: _PhaseBadge(
        label: _stateLabel(context, focus),
        color: phaseColor,
        isDark: isDark,
      ),
      actions: [
        CoinBalanceChip(onTap: () => CoinPurchaseSheet.show(context)),
      ],
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final ringSize = (box.maxHeight * 0.92).clamp(120.0, 220.0);
              final size = ringSize > box.maxWidth ? box.maxWidth * 0.82 : ringSize;
              final treeSize = size * 0.44;
              final timerSize = (size * 0.16).clamp(26.0, 40.0);

              return Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: treeProgress),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (_, animatedTree, __) {
                    return FocusProgressRing(
                      progress: ringProgress,
                      color: phaseColor,
                      size: size,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TreeWidget(
                            progress: animatedTree,
                            style: shop.activeTreeStyle,
                            size: treeSize,
                          ),
                          SizedBox(height: size * 0.02),
                          Text(
                            focus.formattedTime,
                            style: AppTypography.displayLarge(color: onSurface).copyWith(
                              fontSize: timerSize,
                              letterSpacing: -1.5,
                              height: 1,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (focus.phase == TimerPhase.focus && focus.isIdle) ...[
          _DurationPicker(focus: focus),
          const SizedBox(height: 6),
          _TagPicker(focus: focus),
          const SizedBox(height: 8),
        ],
        if (focus.phase == TimerPhase.focus && !focus.sessionQualifiesForReward)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _HintBanner(text: AppStrings.t(context, 'starRewardHint')),
          ),
        if (shop.hasWhiteNoise && focus.phase == TimerPhase.focus)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: FilterChip(
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              selected: focus.whiteNoiseEnabled,
              onSelected: (_) => focus.toggleWhiteNoise(),
              label: Text(AppStrings.t(context, 'whiteNoise'), style: const TextStyle(fontSize: 12)),
            ),
          ),
        _DailyGoalBar(focus: focus, isDark: isDark),
        const SizedBox(height: 8),
        _ActionButtons(focus: focus, primary: primary),
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

class _PhaseBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _PhaseBadge({required this.label, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final FocusProvider focus;
  final Color primary;

  const _ActionButtons({required this.focus, required this.primary});

  @override
  Widget build(BuildContext context) {
    final showStop = focus.isRunning || focus.isPaused;
    final isPrimary = !focus.isRunning;

    final buttonStyle = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );

    return Row(
      children: [
        if (showStop) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: focus.stop,
              style: buttonStyle.copyWith(
                foregroundColor: const WidgetStatePropertyAll(AppColors.onSurfaceVariant),
                side: WidgetStatePropertyAll(
                  BorderSide(color: AppColors.onSurfaceVariant.withValues(alpha: 0.22)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(AppStrings.t(context, 'stop'), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: showStop ? 2 : 1,
          child: FilledButton(
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
            style: buttonStyle.copyWith(
              backgroundColor: WidgetStatePropertyAll(isPrimary ? primary : primary.withValues(alpha: 0.88)),
              foregroundColor: const WidgetStatePropertyAll(Colors.white),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  focus.isRunning
                      ? Icons.pause_rounded
                      : focus.isCompleted && focus.phase != TimerPhase.focus
                          ? Icons.skip_next_rounded
                          : Icons.play_arrow_rounded,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(_label(context, focus), style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
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

class _HintBanner extends StatelessWidget {
  final String text;

  const _HintBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppColors.warning.withValues(alpha: 0.95), height: 1.3),
      ),
    );
  }
}

class _DailyGoalBar extends StatelessWidget {
  final FocusProvider focus;
  final bool isDark;

  const _DailyGoalBar({required this.focus, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final reached = focus.dailyGoalProgress >= 1;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(AppStrings.t(context, 'dailyGoal'), style: AppTypography.labelBold(size: 12)),
              const Spacer(),
              Text(
                reached
                    ? AppStrings.t(context, 'goalReached')
                    : AppStrings.t(context, 'goalProgress', {
                        'done': '${focus.stats.todayMinutes}',
                        'goal': '${focus.dailyGoalMinutes}',
                      }),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: reached ? primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: focus.dailyGoalProgress,
              minHeight: 4,
              backgroundColor: primary.withValues(alpha: 0.12),
              color: primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagPicker extends StatelessWidget {
  final FocusProvider focus;

  const _TagPicker({required this.focus});

  IconData _icon(String id) => switch (id) {
        FocusTag.work => Icons.work_outline,
        FocusTag.read => Icons.menu_book_outlined,
        FocusTag.other => Icons.spa_outlined,
        _ => Icons.school_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: FocusTag.all.map((tag) {
        final selected = focus.selectedTag == tag;
        return GestureDetector(
          onTap: () => focus.setSelectedTag(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? primary : AppColors.onSurfaceVariant.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_icon(tag), size: 13, color: selected ? Colors.white : AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  AppStrings.t(context, FocusTag.labelKey(tag)),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final FocusProvider focus;

  const _DurationPicker({required this.focus});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: focus.availableDurations.map((mins) {
        final selected = focus.focusDurationMinutes == mins;
        return GestureDetector(
          onTap: () => focus.setFocusDuration(mins),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? primary : AppColors.onSurfaceVariant.withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              '${mins}m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
