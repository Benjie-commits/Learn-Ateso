import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/firebase/firestore_content_repository.dart';
import 'package:learn_ateso/data/firebase/firestore_paths.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreContentRepository repo;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repo = FirestoreContentRepository(firestore: firestore);

    await firestore.collection(FirestorePaths.levels).doc('level_1').set({
      'name': 'Level 1: Greetings',
      'order': 1,
      'puzzle': {'totalPieces': 2},
    });
    await firestore.collection(FirestorePaths.levels).doc('level_2').set({
      'name': 'Level 2: Everyday Phrases',
      'order': 2,
      'puzzle': {'totalPieces': 2},
    });

    await firestore
        .collection(FirestorePaths.lessonsForLevel('level_1'))
        .doc('lesson_1_2')
        .set({'title': 'Introducing Yourself', 'order': 2});
    await firestore
        .collection(FirestorePaths.lessonsForLevel('level_1'))
        .doc('lesson_1_1')
        .set({'title': 'Saying Hello', 'order': 1});

    await firestore.collection(FirestorePaths.lessonContent).doc('lesson_1_1').set({
      'vocabulary': [
        {'word': '[Word 1]', 'translation': 'Hello (placeholder)', 'audioRef': null, 'category': 'greetings'},
      ],
      'grammarNote': 'PLACEHOLDER note',
      'quiz': [
        {'prompt': 'Which word means "Hello"?', 'options': ['[Word 1]', '[Word 2]'], 'correctOptionIndex': 0},
      ],
      'sentenceExercise': {
        'promptTranslation': 'Arrange the words',
        'scrambledWords': ['[Word 1]'],
        'correctOrder': ['[Word 1]'],
      },
      'dialogue': {
        'scenario': 'Greeting a neighbor',
        'turns': [
          {'speaker': 'npc', 'line': '[Word 1]!', 'responseOptions': [], 'correctResponseIndex': null},
        ],
      },
    });

    await firestore.collection(FirestorePaths.aptitudeTests).doc('level_2').set({
      'questions': [
        {'prompt': 'Which word means "Hello"?', 'options': ['[Word 1]', '[Word 6]'], 'correctOptionIndex': 0},
      ],
      'passThreshold': 1,
    });
  });

  group('FirestoreContentRepository', () {
    test('getLevels returns levels ordered by order field', () async {
      final levels = await repo.getLevels();
      expect(levels.map((l) => l.id), ['level_1', 'level_2']);
    });

    test('getLessonsForLevel returns lessons ordered by order field', () async {
      final lessons = await repo.getLessonsForLevel('level_1');
      expect(lessons.map((l) => l.id), ['lesson_1_1', 'lesson_1_2']);
    });

    test('getLessonContent bundles vocabulary, quiz, sentence, and dialogue', () async {
      final content = await repo.getLessonContent('lesson_1_1');
      expect(content.vocabulary, hasLength(1));
      expect(content.quiz, hasLength(1));
      expect(content.sentenceExercise.correctOrder, ['[Word 1]']);
      expect(content.dialogue.turns, hasLength(1));
    });

    test('getLessonContent throws for a lesson with no seeded content', () async {
      expect(() => repo.getLessonContent('unknown_lesson'), throwsStateError);
    });

    test('getAptitudeTest returns the seeded test for a level', () async {
      final aptitudeTest = await repo.getAptitudeTest('level_2');
      expect(aptitudeTest.questions, hasLength(1));
      expect(aptitudeTest.passThreshold, 1);
    });

    test('getAptitudeTest throws for a level with no seeded test', () async {
      expect(() => repo.getAptitudeTest('level_1'), throwsStateError);
    });
  });
}
