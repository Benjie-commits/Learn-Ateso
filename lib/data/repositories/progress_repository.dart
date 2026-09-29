import '../../models/level_progress.dart';
import '../../models/user_progress.dart';

abstract class ProgressRepository {
  Stream<UserProgress> watchProgress(String userId);

  Stream<LevelProgress> watchLevelProgress(String userId, String levelId);

  /// Records a lesson as complete for [userId], updates points/streak, and
  /// reveals the lesson's puzzle piece. Returns the updated level progress.
  Future<LevelProgress> recordLessonCompletion({
    required String userId,
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
