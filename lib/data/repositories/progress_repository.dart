import '../../models/leaderboard_entry.dart';
import '../../models/level_progress.dart';
import '../../models/user_progress.dart';

abstract class ProgressRepository {
  Stream<UserProgress> watchProgress(String userId);

  Stream<LevelProgress> watchLevelProgress(String userId, String levelId);

  /// Top [limit] users by points, descending. Backed by a denormalized
  /// public record (see LeaderboardEntry) kept in sync by
  /// [recordLessonCompletion], not by reading every user's private progress.
  Stream<List<LeaderboardEntry>> watchLeaderboard({int limit = 20});

  /// Records a lesson as complete for [userId], updates points/streak, and
  /// reveals the lesson's puzzle piece. Returns the updated level progress.
  /// [userName] is denormalized onto the user's leaderboard entry.
  Future<LevelProgress> recordLessonCompletion({
    required String userId,
    required String userName,
    required String lessonId,
    required String levelId,
    required int quizScore,
  });

  /// Records the result of a level's aptitude/skip test. On pass, the level
  /// is fully unlocked; on fail, it stays locked.
  Future<LevelProgress> recordAptitudeTestResult({
    required String userId,
    required String levelId,
    required bool passed,
  });
}
