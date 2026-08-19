class FocusSession {
  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final bool completed;
  final String tag;

  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.completed,
    this.tag = 'study',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'completed': completed,
        'tag': tag,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: DateTime.parse(json['completedAt'] as String),
        durationSeconds: json['durationSeconds'] as int,
        completed: json['completed'] as bool? ?? true,
        tag: json['tag'] as String? ?? 'study',
      );
}

class FocusStats {
  final int totalSessions;
  final int totalMinutes;
  final int todayMinutes;
  final int currentStreak;
  final int treesGrown;
  final int weekMinutes;
  final int bestDayMinutes;

  const FocusStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.todayMinutes,
    required this.currentStreak,
    required this.treesGrown,
    this.weekMinutes = 0,
    this.bestDayMinutes = 0,
  });

  static const empty = FocusStats(
    totalSessions: 0,
    totalMinutes: 0,
    todayMinutes: 0,
    currentStreak: 0,
    treesGrown: 0,
  );
}

class FocusAchievement {
  final String id;
  final String titleKey;
  final String descKey;
  final bool unlocked;

  const FocusAchievement({
    required this.id,
    required this.titleKey,
    required this.descKey,
    required this.unlocked,
  });
}

class DayMinutes {
  final DateTime day;
  final int minutes;

  const DayMinutes({required this.day, required this.minutes});
}

class FocusTag {
  static const study = 'study';
  static const work = 'work';
  static const read = 'read';
  static const other = 'other';
  static const all = [study, work, read, other];

  static String labelKey(String id) => switch (id) {
        work => 'tagWork',
        read => 'tagRead',
        other => 'tagOther',
        _ => 'tagStudy',
      };
}

enum TimerPhase { focus, shortBreak, longBreak }

enum TimerState { idle, running, paused, completed }
