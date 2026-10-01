import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/cached_content_repository.dart';
import 'package:learn_ateso/data/fake/fake_content_repository.dart';
import 'package:learn_ateso/data/local/local_download_repository.dart';
import 'package:learn_ateso/models/dialogue_module.dart';
import 'package:learn_ateso/models/lesson.dart';
import 'package:learn_ateso/models/lesson_content.dart';
import 'package:learn_ateso/models/level.dart';
import 'package:learn_ateso/models/puzzle.dart';
import 'package:learn_ateso/models/quiz_question.dart';
import 'package:learn_ateso/models/sentence_exercise.dart';
import 'package:learn_ateso/models/vocabulary_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('passes through to the inner repository when nothing is downloaded', () async {
    final inner = FakeContentRepository();
    final repo = CachedContentRepository(inner, LocalDownloadRepository());

    final lessons = await repo.getLessonsForLevel('level_1');
    expect(lessons, await inner.getLessonsForLevel('level_1'));

    final content = await repo.getLessonContent('lesson_1_1');
    expect(content.vocabulary, (await inner.getLessonContent('lesson_1_1')).vocabulary);
  });

  test('serves the downloaded copy instead of the inner repository once cached', () async {
    final inner = FakeContentRepository();
    final downloads = LocalDownloadRepository();
    final repo = CachedContentRepository(inner, downloads);

    const offlineLesson = Lesson(id: 'lesson_1_1', levelId: 'level_1', title: 'Offline copy', order: 1);
    const offlineContent = LessonContent(
      lessonId: 'lesson_1_1',
      vocabulary: [VocabularyItem(word: '[Offline]', translation: 'Offline', audioRef: null, category: 'test')],
      grammarNote: 'offline grammar note',
      quiz: [QuizQuestion(prompt: 'offline?', options: ['yes'], correctOptionIndex: 0)],
      sentenceExercise: SentenceExercise(promptTranslation: 'offline', scrambledWords: [], correctOrder: []),
      dialogue: DialogueModule(id: 'lesson_1_1-dialogue', scenario: 'offline', turns: []),
    );

    await downloads.downloadLevel(
      level: const Level(id: 'level_1', name: 'Level 1', order: 1, puzzle: Puzzle(id: 'p', totalPieces: 1)),
      lessons: const [offlineLesson],
      contentByLessonId: {'lesson_1_1': offlineContent},
    );

    final lessons = await repo.getLessonsForLevel('level_1');
    expect(lessons.single.title, 'Offline copy');

    final content = await repo.getLessonContent('lesson_1_1');
    expect(content.vocabulary.single.word, '[Offline]');
  });
}
