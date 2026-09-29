class UserProgress {
  const UserProgress({
    required this.points,
    required this.streakDays,
    required this.lastActive,
  });

  final int points;
  final int streakDays;
  final DateTime lastActive;

  static UserProgress empty() => UserProgress(
        points: 0,
        streakDays: 0,
        lastActive: DateTime.now(),
      );

  UserProgress copyWith({int? points, int? streakDays, DateTime? lastActive}) {
    return UserProgress(
      points: points ?? this.points,
      streakDays: streakDays ?? this.streakDays,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      points: map['points'] as int? ?? 0,
      streakDays: map['streakDays'] as int? ?? 0,
      lastActive: DateTime.tryParse(map['lastActive'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'points': points,
      'streakDays': streakDays,
      'lastActive': lastActive.toIso8601String(),
    };
  }
}
