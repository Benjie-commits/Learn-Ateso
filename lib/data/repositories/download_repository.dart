import '../../models/lesson.dart';
import '../../models/lesson_content.dart';
import '../../models/level.dart';

/// Device-local storage for lessons a user has chosen to save for offline
/// access (SRS 3.6). Deliberately separate from the auth/progress/content
/// repositories — "downloaded" is inherently per-device, not per-account, so
/// nothing here ever touches Firestore.
abstract class DownloadRepository {
  Future<Set<String>> getDownloadedLevelIds();

  /// Persists [level]'s lesson list and every lesson's full content so the
  /// whole level can be browsed and completed with zero network calls.
  Future<void> downloadLevel({
    required Level level,
    required List<Lesson> lessons,
    required Map<String, LessonContent> contentByLessonId,
  });

  Future<void> removeDownload(String levelId);

  /// Null if this level hasn't been downloaded.
  Future<List<Lesson>?> getCachedLessons(String levelId);

  /// Null if this lesson's content hasn't been downloaded.
  Future<LessonContent?> getCachedLessonContent(String lessonId);
}
