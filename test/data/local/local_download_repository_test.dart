import 'package:flutter_test/flutter_test.dart';
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
  const level = Level(
    id: 'level_1',
    name: 'Level 1: Greetings',
    order: 1,
    puzzle: Puzzle(id: 'level_1-puzzle', totalPieces: 2),
  );
  const lessons = [
    Lesson(id: 'lesson_1_1', levelId: 'level_1', title: 'Saying Hello', order: 1),
  ];
  const content = LessonContent(
    lessonId: 'lesson_1_1',
    vocabulary: [VocabularyItem(word: '[Word 1]', translation: 'Hello', audioRef: null, category: 'greetings')],
    grammarNote: 'PLACEHOLDER',
    quiz: [QuizQuestion(prompt: 'Which word means "Hello"?', options: ['[Word 1]'], correctOptionIndex: 0)],
    sentenceExercise: SentenceExercise(
      promptTranslation: 'Say hello',
      scrambledWords: ['[Word 1]'],
      correctOrder: ['[Word 1]'],
    ),
    dialogue: DialogueModule(
      id: 'lesson_1_1-dialogue',
      scenario: 'Greeting a neighbor',
      turns: [DialogueTurn(speaker: 'npc', line: '[Word 1]!')],
    ),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('a level is not downloaded until downloadLevel is called', () async {
    final repo = LocalDownloadRepository();

    expect(await repo.getDownloadedLevelIds(), isEmpty);
    expect(await repo.getCachedLessons(level.id), isNull);
    expect(await repo.getCachedLessonContent('lesson_1_1'), isNull);
  });

  test('downloadLevel persists the level id, lessons, and lesson content', () async {
    final repo = LocalDownloadRepository();

    await repo.downloadLevel(level: level, lessons: lessons, contentByLessonId: {'lesson_1_1': content});

    expect(await repo.getDownloadedLevelIds(), {'level_1'});

    final cachedLessons = await repo.getCachedLessons('level_1');
    expect(cachedLessons, isNotNull);
    expect(cachedLessons!.single.id, 'lesson_1_1');
    expect(cachedLessons.single.title, 'Saying Hello');

    final cachedContent = await repo.getCachedLessonContent('lesson_1_1');
    expect(cachedContent, isNotNull);
    expect(cachedContent!.vocabulary.single.word, '[Word 1]');
    expect(cachedContent.dialogue.turns.single.line, '[Word 1]!');
  });

  test('removeDownload clears the level id, lessons, and lesson content', () async {
    final repo = LocalDownloadRepository();
    await repo.downloadLevel(level: level, lessons: lessons, contentByLessonId: {'lesson_1_1': content});

    await repo.removeDownload('level_1');

    expect(await repo.getDownloadedLevelIds(), isEmpty);
    expect(await repo.getCachedLessons('level_1'), isNull);
    expect(await repo.getCachedLessonContent('lesson_1_1'), isNull);
  });
}
