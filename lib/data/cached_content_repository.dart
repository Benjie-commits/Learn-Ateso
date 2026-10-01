import '../models/aptitude_test.dart';
import '../models/lesson.dart';
import '../models/lesson_content.dart';
import '../models/level.dart';
import 'repositories/content_repository.dart';
import 'repositories/download_repository.dart';

/// Wraps the real [ContentRepository] with a cache-first read for lessons
/// and lesson content: once a level has been downloaded (see
/// DownloadRepository), its lessons/content are served from local storage
/// with zero network calls, which is what makes the full lesson pipeline
/// (vocab -> grammar -> quiz -> sentence -> conversation) work offline for
/// downloaded levels (SRS 3.6, 4.1).
///
/// Deliberate scope cut: [getLevels] and [getAptitudeTest] are always
/// passed through uncached — the level list is lightweight metadata, not
/// "a lesson," and the harder half of the SRS's offline story (queuing
/// progress writes made while offline and auto-syncing on reconnect) is not
/// implemented here; this repository only covers offline *content* access.
class CachedContentRepository implements ContentRepository {
  CachedContentRepository(this._inner, this._downloads);

  final ContentRepository _inner;
  final DownloadRepository _downloads;

  @override
  Future<List<Level>> getLevels() => _inner.getLevels();

  @override
  Future<List<Lesson>> getLessonsForLevel(String levelId) async {
    final cached = await _downloads.getCachedLessons(levelId);
    if (cached != null) return cached;
    return _inner.getLessonsForLevel(levelId);
  }

  @override
  Future<LessonContent> getLessonContent(String lessonId) async {
    final cached = await _downloads.getCachedLessonContent(lessonId);
    if (cached != null) return cached;
    return _inner.getLessonContent(lessonId);
  }

  @override
  Future<AptitudeTest> getAptitudeTest(String levelId) => _inner.getAptitudeTest(levelId);
}
