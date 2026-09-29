import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/fake/fake_content_repository.dart';

void main() {
  group('FakeContentRepository', () {
    final repo = FakeContentRepository();

    test('getLevels returns seeded levels in order', () async {
      final levels = await repo.getLevels();
      expect(levels, isNotEmpty);
      for (var i = 1; i < levels.length; i++) {
        expect(levels[i].order, greaterThan(levels[i - 1].order));
      }
    });

    test('getLessonsForLevel returns lessons in order', () async {
      final lessons = await repo.getLessonsForLevel('level_1');
      expect(lessons.length, 2);
      expect(lessons.first.order, 1);
    });

    test('getLessonContent bundles vocabulary, quiz, sentence, and dialogue', () async {
      final content = await repo.getLessonContent('lesson_1_1');
      expect(content.vocabulary, isNotEmpty);
      expect(content.quiz, isNotEmpty);
      expect(content.sentenceExercise.correctOrder, isNotEmpty);
      expect(content.dialogue.turns, isNotEmpty);
    });

    test('getAptitudeTest throws for a level with no seeded test', () async {
      expect(() => repo.getAptitudeTest('level_1'), throwsStateError);
    });

    test('getAptitudeTest returns questions for a seeded level', () async {
      final test = await repo.getAptitudeTest('level_2');
      expect(test.questions, isNotEmpty);
      expect(test.passThreshold, greaterThan(0));
    });
  });
}
