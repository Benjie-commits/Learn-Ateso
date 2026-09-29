import '../../models/aptitude_test.dart';
import '../../models/lesson.dart';
import '../../models/lesson_content.dart';
import '../../models/level.dart';
import '../repositories/content_repository.dart';
import 'seed_data.dart';

class FakeContentRepository implements ContentRepository {
  @override
  Future<List<Level>> getLevels() async {
    final levels = [...SeedData.levels];
    levels.sort((a, b) => a.order.compareTo(b.order));
    return levels;
  }

  @override
  Future<List<Lesson>> getLessonsForLevel(String levelId) async {
    final lessons = [...(SeedData.lessonsByLevel[levelId] ?? const <Lesson>[])];
    lessons.sort((a, b) => a.order.compareTo(b.order));
    return lessons;
  }

  @override
  Future<LessonContent> getLessonContent(String lessonId) async {
    final content = SeedData.lessonContent[lessonId];
    if (content == null) {
      throw StateError('No content seeded for lesson $lessonId');
    }
    return content;
  }

  @override
  Future<AptitudeTest> getAptitudeTest(String levelId) async {
    final test = SeedData.aptitudeTests[levelId];
    if (test == null) {
      throw StateError('No aptitude test seeded for level $levelId');
    }
    return test;
  }
}
