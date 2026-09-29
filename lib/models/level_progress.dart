/// Per-user progress against one Level. This is where `unlocked` actually
/// lives — see the note in level.dart on why it isn't a Level field.
class LevelProgress {
  const LevelProgress({
    required this.levelId,
    required this.unlocked,
    required this.completedLessonIds,
    required this.revealedPuzzlePositions,
  });

  final String levelId;
  final bool unlocked;
  final Set<String> completedLessonIds;
  final Set<int> revealedPuzzlePositions;

  static LevelProgress empty(String levelId, {bool unlocked = false}) {
    return LevelProgress(
      levelId: levelId,
      unlocked: unlocked,
      completedLessonIds: const {},
      revealedPuzzlePositions: const {},
    );
  }

  LevelProgress copyWith({
    bool? unlocked,
    Set<String>? completedLessonIds,
    Set<int>? revealedPuzzlePositions,
  }) {
    return LevelProgress(
      levelId: levelId,
      unlocked: unlocked ?? this.unlocked,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      revealedPuzzlePositions:
          revealedPuzzlePositions ?? this.revealedPuzzlePositions,
    );
  }

  factory LevelProgress.fromMap(String levelId, Map<String, dynamic> map) {
    return LevelProgress(
      levelId: levelId,
      unlocked: map['unlocked'] as bool? ?? false,
      completedLessonIds:
          ((map['completedLessonIds'] as List?)?.cast<String>() ?? const [])
              .toSet(),
      revealedPuzzlePositions:
          ((map['revealedPuzzlePositions'] as List?)?.cast<int>() ?? const [])
              .toSet(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unlocked': unlocked,
      'completedLessonIds': completedLessonIds.toList(),
      'revealedPuzzlePositions': revealedPuzzlePositions.toList(),
    };
  }
}
