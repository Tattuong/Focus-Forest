import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/storage_service.dart';
import '../models/focus_session.dart';
import 'shop_provider.dart';

class FocusProvider extends ChangeNotifier {
  static const _sessionsKey = 'ff_focus_sessions';
  static const _streakKey = 'ff_focus_streak';
  static const _lastSessionDateKey = 'ff_last_session_date';
  static const _focusDurationKey = 'ff_focus_duration';
  static const _whiteNoiseKey = 'ff_white_noise';
  static const _dailyGoalKey = 'ff_daily_goal';
  static const _shortBreakKey = 'ff_short_break';
  static const _longBreakKey = 'ff_long_break';
  static const _tagKey = 'ff_session_tag';

  static const int defaultFocusMinutes = 25;
  static const int defaultShortBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultDailyGoalMinutes = 60;

  final _uuid = const Uuid();

  List<FocusSession> _sessions = [];
  FocusStats _stats = FocusStats.empty;
  TimerState _timerState = TimerState.idle;
  TimerPhase _phase = TimerPhase.focus;
  int _remainingSeconds = defaultFocusMinutes * 60;
  int _totalSeconds = defaultFocusMinutes * 60;
  int _focusDurationMinutes = defaultFocusMinutes;
  int _shortBreakMinutes = defaultShortBreakMinutes;
  int _longBreakMinutes = defaultLongBreakMinutes;
  int _dailyGoalMinutes = defaultDailyGoalMinutes;
  int _completedFocusToday = 0;
  int _currentStreak = 0;
  String _selectedTag = FocusTag.study;
  bool _whiteNoiseEnabled = false;
  Timer? _ticker;
  ShopProvider? _shop;

  List<FocusSession> get sessions => List.unmodifiable(_sessions);
  FocusStats get stats => _stats;
  TimerState get timerState => _timerState;
  TimerPhase get phase => _phase;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get focusDurationMinutes => _focusDurationMinutes;
  int get shortBreakMinutes => _shortBreakMinutes;
  int get longBreakMinutes => _longBreakMinutes;
  int get dailyGoalMinutes => _dailyGoalMinutes;
  String get selectedTag => _selectedTag;
  bool get whiteNoiseEnabled => _whiteNoiseEnabled;
  double get progress => _totalSeconds == 0 ? 0 : 1 - (_remainingSeconds / _totalSeconds);
  double get dailyGoalProgress => _dailyGoalMinutes == 0 ? 0 : (_stats.todayMinutes / _dailyGoalMinutes).clamp(0.0, 1.0);

  bool get isRunning => _timerState == TimerState.running;
  bool get isPaused => _timerState == TimerState.paused;
  bool get isIdle => _timerState == TimerState.idle;
  bool get isCompleted => _timerState == TimerState.completed;

  String get formattedTime {
    final m = _remainingSeconds ~/ 60;
    final s = _remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void bindShop(ShopProvider shop) => _shop = shop;

  Future<void> load() async {
    final raw = await StorageService.instance.getString(_sessionsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _sessions = list.map((e) => FocusSession.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('Focus sessions parse error: $e');
        _sessions = [];
      }
    }
    _currentStreak = await StorageService.instance.getInt(_streakKey) ?? 0;
    _focusDurationMinutes = await StorageService.instance.getInt(_focusDurationKey) ?? defaultFocusMinutes;
    _shortBreakMinutes = await StorageService.instance.getInt(_shortBreakKey) ?? defaultShortBreakMinutes;
    _longBreakMinutes = await StorageService.instance.getInt(_longBreakKey) ?? defaultLongBreakMinutes;
    _dailyGoalMinutes = await StorageService.instance.getInt(_dailyGoalKey) ?? defaultDailyGoalMinutes;
    _selectedTag = await StorageService.instance.getString(_tagKey) ?? FocusTag.study;
    _whiteNoiseEnabled = await StorageService.instance.getBool(_whiteNoiseKey) ?? false;
    _recomputeStats();
    _resetPhase(TimerPhase.focus);
    notifyListeners();
  }

  List<int> get availableDurations => const [15, 25, 45, 60];
  List<int> get availableGoals => const [25, 50, 60, 90, 120];
  List<int> get availableShortBreaks => const [5, 10, 15];
  List<int> get availableLongBreaks => const [15, 20, 30];

  Future<void> setFocusDuration(int minutes) async {
    if (!availableDurations.contains(minutes)) return;
    _focusDurationMinutes = minutes;
    await StorageService.instance.saveInt(_focusDurationKey, minutes);
    if (_timerState == TimerState.idle) {
      _resetPhase(TimerPhase.focus);
    }
    notifyListeners();
  }

  Future<void> setShortBreak(int minutes) async {
    if (!availableShortBreaks.contains(minutes)) return;
    _shortBreakMinutes = minutes;
    await StorageService.instance.saveInt(_shortBreakKey, minutes);
    if (_timerState == TimerState.idle && _phase == TimerPhase.shortBreak) {
      _resetPhase(TimerPhase.shortBreak);
    }
    notifyListeners();
  }

  Future<void> setLongBreak(int minutes) async {
    if (!availableLongBreaks.contains(minutes)) return;
    _longBreakMinutes = minutes;
    await StorageService.instance.saveInt(_longBreakKey, minutes);
    if (_timerState == TimerState.idle && _phase == TimerPhase.longBreak) {
      _resetPhase(TimerPhase.longBreak);
    }
    notifyListeners();
  }

  Future<void> setDailyGoal(int minutes) async {
    if (!availableGoals.contains(minutes)) return;
    _dailyGoalMinutes = minutes;
    await StorageService.instance.saveInt(_dailyGoalKey, minutes);
    notifyListeners();
  }

  Future<void> setSelectedTag(String tag) async {
    if (!FocusTag.all.contains(tag)) return;
    _selectedTag = tag;
    await StorageService.instance.saveString(_tagKey, tag);
    notifyListeners();
  }

  Future<void> toggleWhiteNoise() async {
    if (_shop?.hasWhiteNoise != true) return;
    _whiteNoiseEnabled = !_whiteNoiseEnabled;
    await StorageService.instance.saveBool(_whiteNoiseKey, _whiteNoiseEnabled);
    notifyListeners();
  }

  void start() {
    if (_timerState == TimerState.running) return;
    if (_timerState == TimerState.completed) {
      _resetPhase(_phase);
    }
    _timerState = TimerState.running;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_timerState != TimerState.running) return;
    _timerState = TimerState.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() => start();

  void stop() {
    _ticker?.cancel();
    _resetPhase(TimerPhase.focus);
    notifyListeners();
  }

  void skipBreak() {
    if (_phase != TimerPhase.shortBreak && _phase != TimerPhase.longBreak) return;
    _resetPhase(TimerPhase.focus);
    notifyListeners();
  }

  Future<void> _onPhaseComplete() async {
    _ticker?.cancel();

    if (_phase == TimerPhase.focus) {
      if (_qualifiesForReward) {
        await _recordSession(completed: true);
        _completedFocusToday++;
        if (_shop != null) {
          await _shop!.rewardForFocusSession();
          if (_completedFocusToday % 4 == 0) {
            await _shop!.rewardForStreakBonus();
          }
        }
      }
      final useLongBreak = _shop?.hasLongBreak == true && _completedFocusToday % 4 == 0;
      _resetPhase(useLongBreak ? TimerPhase.longBreak : TimerPhase.shortBreak);
      _timerState = TimerState.completed;
    } else {
      _resetPhase(TimerPhase.focus);
      _timerState = TimerState.completed;
    }
    notifyListeners();
  }

  Future<void> _recordSession({required bool completed}) async {
    final now = DateTime.now();
    final session = FocusSession(
      id: _uuid.v4(),
      startedAt: now.subtract(Duration(seconds: _totalSeconds - _remainingSeconds)),
      completedAt: now,
      durationSeconds: _totalSeconds - _remainingSeconds,
      completed: completed,
      tag: _selectedTag,
    );
    _sessions.insert(0, session);
    if (_sessions.length > 500) {
      _sessions = _sessions.take(500).toList();
    }
    await _updateStreak(now);
    await _saveSessions();
    _recomputeStats();
  }

  Future<void> _updateStreak(DateTime now) async {
    final today = _dateKey(now);
    final last = await StorageService.instance.getString(_lastSessionDateKey);
    if (last == today) return;

    if (last != null) {
      final lastDate = DateTime.tryParse(last);
      if (lastDate != null) {
        final diff = now.difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
        _currentStreak = diff == 1 ? _currentStreak + 1 : 1;
      } else {
        _currentStreak = 1;
      }
    } else {
      _currentStreak = 1;
    }
    await StorageService.instance.saveString(_lastSessionDateKey, today);
    await StorageService.instance.saveInt(_streakKey, _currentStreak);
  }

  void _resetPhase(TimerPhase phase) {
    _phase = phase;
    final minutes = switch (phase) {
      TimerPhase.focus => _focusDurationMinutes,
      TimerPhase.shortBreak => _shortBreakMinutes,
      TimerPhase.longBreak => _longBreakMinutes,
    };
    _totalSeconds = minutes * 60;
    _remainingSeconds = _totalSeconds;
    if (_timerState != TimerState.running) {
      _timerState = TimerState.idle;
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _remainingSeconds = 0;
        _onPhaseComplete();
        return;
      }
      _remainingSeconds--;
      notifyListeners();
    });
  }

  void _recomputeStats() {
    final now = DateTime.now();
    final todayKey = _dateKey(now);
    var totalMinutes = 0;
    var todayMinutes = 0;
    var trees = 0;

    for (final s in _sessions.where((e) => e.completed)) {
      final mins = (s.durationSeconds / 60).round();
      totalMinutes += mins;
      trees++;
      if (_dateKey(s.completedAt) == todayKey) {
        todayMinutes += mins;
      }
    }

    var weekMinutes = 0;
    var bestDay = 0;
    for (final day in last7Days) {
      weekMinutes += day.minutes;
      if (day.minutes > bestDay) bestDay = day.minutes;
    }

    _stats = FocusStats(
      totalSessions: _sessions.where((e) => e.completed).length,
      totalMinutes: totalMinutes,
      todayMinutes: todayMinutes,
      currentStreak: _currentStreak,
      treesGrown: trees,
      weekMinutes: weekMinutes,
      bestDayMinutes: bestDay,
    );
  }

  List<DayMinutes> get last7Days {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final key = _dateKey(day);
      final mins = _sessions
          .where((s) => s.completed && _dateKey(s.completedAt) == key)
          .fold<int>(0, (sum, s) => sum + (s.durationSeconds / 60).round());
      return DayMinutes(day: day, minutes: mins);
    });
  }

  List<FocusAchievement> get achievements {
    final trees = _stats.treesGrown;
    final streak = _stats.currentStreak;
    final total = _stats.totalMinutes;
    return [
      FocusAchievement(id: 'first', titleKey: 'achFirstTitle', descKey: 'achFirstDesc', unlocked: trees >= 1),
      FocusAchievement(id: 'trees10', titleKey: 'achTreesTitle', descKey: 'achTreesDesc', unlocked: trees >= 10),
      FocusAchievement(id: 'streak3', titleKey: 'achStreak3Title', descKey: 'achStreak3Desc', unlocked: streak >= 3),
      FocusAchievement(id: 'streak7', titleKey: 'achStreak7Title', descKey: 'achStreak7Desc', unlocked: streak >= 7),
      FocusAchievement(id: 'hour', titleKey: 'achHourTitle', descKey: 'achHourDesc', unlocked: total >= 60),
      FocusAchievement(id: 'goal', titleKey: 'achGoalTitle', descKey: 'achGoalDesc', unlocked: _stats.todayMinutes >= _dailyGoalMinutes && _stats.todayMinutes > 0),
    ];
  }

  Future<void> _saveSessions() async {
    final encoded = jsonEncode(_sessions.map((e) => e.toJson()).toList());
    await StorageService.instance.saveString(_sessionsKey, encoded);
  }

  String exportStats(String Function(String key) t, {bool includeWatermark = true}) {
    final buffer = StringBuffer()
      ..writeln('${t('exportTitle')}: ${DateTime.now().toIso8601String()}')
      ..writeln('${t('statTotalSessions')}: ${_stats.totalSessions}')
      ..writeln('${t('statTotalTime')}: ${_stats.totalMinutes} min')
      ..writeln('${t('statTodayTime')}: ${_stats.todayMinutes} min')
      ..writeln('${t('statStreak')}: ${_stats.currentStreak}')
      ..writeln('${t('statTrees')}: ${_stats.treesGrown}')
      ..writeln('')
      ..writeln(t('exportRecentSessions'));

    for (final s in _sessions.take(30)) {
      buffer.writeln('- ${s.completedAt.toIso8601String()} (${(s.durationSeconds / 60).round()} min)');
    }

    if (includeWatermark) {
      buffer.writeln('\n--- Focus Forest ---');
    }
    return buffer.toString();
  }

  /// Stars, tree growth & stats only when the full focus session is at least 20 minutes.
  bool get _qualifiesForReward =>
      _focusDurationMinutes >= IapConstants.minFocusMinutesForReward;

  bool get sessionQualifiesForReward => _qualifiesForReward;

  String _dateKey(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
