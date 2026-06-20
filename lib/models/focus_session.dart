class FocusSession {
  final String id;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final bool completed;

  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'completed': completed,
      };

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
        id: json['id'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: DateTime.parse(json['completedAt'] as String),
        durationSeconds: json['durationSeconds'] as int,
        completed: json['completed'] as bool? ?? true,
      );
}

class FocusStats {
  final int totalSessions;
  final int totalMinutes;
  final int todayMinutes;
  final int currentStreak;
  final int treesGrown;

  const FocusStats({
    required this.totalSessions,
    required this.totalMinutes,
    required this.todayMinutes,
    required this.currentStreak,
    required this.treesGrown,
  });

  static const empty = FocusStats(
    totalSessions: 0,
    totalMinutes: 0,
    todayMinutes: 0,
    currentStreak: 0,
    treesGrown: 0,
  );
}

enum TimerPhase { focus, shortBreak, longBreak }

enum TimerState { idle, running, paused, completed }
