import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/fake/fake_progress_repository.dart';

void main() {
  group('FakeProgressRepository', () {
    const userId = 'user-1';

    test('level_1 is unlocked by default, level_2 is not', () async {
      final repo = FakeProgressRepository();
      final level1 = await repo.watchLevelProgress(userId, 'level_1').first;
      final level2 = await repo.watchLevelProgress(userId, 'level_2').first;

      expect(level1.unlocked, isTrue);
      expect(level2.unlocked, isFalse);
    });

    test('completing a lesson reveals a puzzle piece and awards points', () async {
      final repo = FakeProgressRepository();

      final result = await repo.recordLessonCompletion(
        userId: userId,
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 2,
      );

      expect(result.completedLessonIds, contains('lesson_1_1'));
      expect(result.revealedPuzzlePositions, isNotEmpty);

      final progress = await repo.watchProgress(userId).first;
      expect(progress.points, greaterThan(0));
    });

    test('completing every lesson in a level auto-unlocks the next level', () async {
      final repo = FakeProgressRepository();

      await repo.recordLessonCompletion(
        userId: userId,
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 2,
      );
      await repo.recordLessonCompletion(
        userId: userId,
        lessonId: 'lesson_1_2',
        levelId: 'level_1',
        quizScore: 2,
      );

      final level2 = await repo.watchLevelProgress(userId, 'level_2').first;
      expect(level2.unlocked, isTrue);
    });

    test('passing the aptitude test unlocks the level directly', () async {
      final repo = FakeProgressRepository();

      final result = await repo.recordAptitudeTestResult(
        userId: userId,
        levelId: 'level_2',
        passed: true,
      );

      expect(result.unlocked, isTrue);
      expect(result.completedLessonIds, isEmpty);
    });

    test('failing the aptitude test keeps the level locked', () async {
      final repo = FakeProgressRepository();

      final result = await repo.recordAptitudeTestResult(
        userId: userId,
        levelId: 'level_2',
        passed: false,
      );

      expect(result.unlocked, isFalse);
    });
  });
}
