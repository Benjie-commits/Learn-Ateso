/// A denormalized, public-readable snapshot of one user's name + points —
/// deliberately kept separate from the private `users/{uid}` document (which
/// holds email) so the leaderboard can be readable by any signed-in user
/// without exposing anyone's contact info.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.points,
  });

  final String userId;
  final String name;
  final int points;

  factory LeaderboardEntry.fromMap(String userId, Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: userId,
      name: map['name'] as String? ?? 'Player',
      points: map['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'points': points};
}
