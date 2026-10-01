import '../../models/leaderboard_entry.dart';
import '../../models/level_progress.dart';
import '../../models/user_progress.dart';
import '../../models/weekly_quest.dart';

abstract class ProgressRepository {
  Stream<UserProgress> watchProgress(String userId);

  Stream<LevelProgress> watchLevelProgress(String userId, String levelId);

  /// Top [limit] users by points, descending. Backed by a denormalized
  /// public record (see LeaderboardEntry) kept in sync by
  /// [recordLessonCompletion], not by reading every user's private progress.
  Stream<List<LeaderboardEntry>> watchLeaderboard({int limit = 20});

  /// This user's active weekly quests, regenerating a fresh set (see
  /// quest_templates.dart) whenever the stored set belongs to a prior week.
  /// Progress toward each quest is kept in sync by [recordLessonCompletion].
  Stream<List<WeeklyQuest>> watchQuests(String userId);

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
