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

  static const int defaultFocusMinutes = 25;
  static const int shortBreakMinutes = 5;
  static const int longBreakMinutes = 15;

  final _uuid = const Uuid();

  List<FocusSession> _sessions = [];
  FocusStats _stats = FocusStats.empty;
  TimerState _timerState = TimerState.idle;
  TimerPhase _phase = TimerPhase.focus;
  int _remainingSeconds = defaultFocusMinutes * 60;
  int _totalSeconds = defaultFocusMinutes * 60;
  int _focusDurationMinutes = defaultFocusMinutes;
  int _completedFocusToday = 0;
  int _currentStreak = 0;
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
  bool get whiteNoiseEnabled => _whiteNoiseEnabled;
  double get progress => _totalSeconds == 0 ? 0 : 1 - (_remainingSeconds / _totalSeconds);

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
    _whiteNoiseEnabled = await StorageService.instance.getBool(_whiteNoiseKey) ?? false;
    _recomputeStats();
    _resetPhase(TimerPhase.focus);
    notifyListeners();
  }

  List<int> get availableDurations {
    if (_shop?.hasCustomTimer == true) {
      return [15, 25, 45, 60];
    }
    return [defaultFocusMinutes];
  }

  Future<void> setFocusDuration(int minutes) async {
    if (!availableDurations.contains(minutes)) return;
    _focusDurationMinutes = minutes;
    await StorageService.instance.saveInt(_focusDurationKey, minutes);
    if (_timerState == TimerState.idle) {
      _resetPhase(TimerPhase.focus);
    }
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
      TimerPhase.shortBreak => shortBreakMinutes,
      TimerPhase.longBreak => longBreakMinutes,
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

    _stats = FocusStats(
      totalSessions: _sessions.where((e) => e.completed).length,
      totalMinutes: totalMinutes,
      todayMinutes: todayMinutes,
      currentStreak: _currentStreak,
      treesGrown: trees,
    );
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
