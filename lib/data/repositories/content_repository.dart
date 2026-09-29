import '../../models/aptitude_test.dart';
import '../../models/lesson.dart';
import '../../models/lesson_content.dart';
import '../../models/level.dart';

abstract class ContentRepository {
  Future<List<Level>> getLevels();

  Future<List<Lesson>> getLessonsForLevel(String levelId);

  /// Bundles vocabulary + grammar note + quiz + sentence exercise + dialogue
  /// for one lesson in a single fetch.
  Future<LessonContent> getLessonContent(String lessonId);

  Future<AptitudeTest> getAptitudeTest(String levelId);
}
