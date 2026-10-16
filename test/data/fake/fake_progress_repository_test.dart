import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/fake/fake_progress_repository.dart';
import 'package:learn_ateso/features/quests/quest_templates.dart';
import 'package:learn_ateso/models/weekly_quest.dart';

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
        userName: 'Ann',
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
        userName: 'Ann',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 2,
      );
      await repo.recordLessonCompletion(
        userId: userId,
        userName: 'Ann',
        lessonId: 'lesson_1_2',
        levelId: 'level_1',
        quizScore: 2,
      );

      final level2 = await repo.watchLevelProgress(userId, 'level_2').first;
      expect(level2.unlocked, isTrue);
    });

    test('recording completions for two users ranks the leaderboard by points descending', () async {
      final repo = FakeProgressRepository();

      await repo.recordLessonCompletion(
        userId: 'user-1',
        userName: 'Ann',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 1,
      );
      await repo.recordLessonCompletion(
        userId: 'user-2',
        userName: 'Ben',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 5,
      );

      final leaderboard = await repo.watchLeaderboard().first;

      expect(leaderboard.first.name, 'Ben');
      expect(leaderboard.first.points, greaterThan(leaderboard.last.points));
    });

    test('a user who has only had progress initialized does not appear on the leaderboard', () async {
      final repo = FakeProgressRepository();

      // watchProgress/watchLevelProgress lazily create a zero-point
      // UserProgress for any signed-in user; the leaderboard must not
      // surface that until they actually complete a lesson.
      await repo.watchProgress(userId).first;
      await repo.watchLevelProgress(userId, 'level_1').first;

      final leaderboard = await repo.watchLeaderboard().first;

      expect(leaderboard, isEmpty);
    });

    test('watchQuests generates 3 active quests for a brand-new user', () async {
      final repo = FakeProgressRepository();
      final quests = await repo.watchQuests(userId).first;

      expect(quests.length, 3);
      expect(quests.every((q) => !q.completed && q.progressValue == 0), isTrue);
    });

    test('completing lessons increments the lessonsCompleted quest and awards a bonus on completion', () async {
      final repo = FakeProgressRepository();
      final quests = await repo.watchQuests(userId).first;
      final lessonsQuest = quests.firstWhere((q) => q.type == QuestType.lessonsCompleted);

      const lessonIds = ['lesson_1_1', 'lesson_1_2', 'lesson_2_1', 'lesson_2_2', 'lesson_3_1'];
      const levelIds = ['level_1', 'level_1', 'level_2', 'level_2', 'level_3'];

      for (var i = 0; i < lessonsQuest.targetValue; i++) {
        await repo.recordLessonCompletion(
          userId: userId,
          userName: 'Ann',
          lessonId: lessonIds[i],
          levelId: levelIds[i],
          quizScore: 1,
        );
      }

      final updatedQuests = await repo.watchQuests(userId).first;
      final updatedLessonsQuest = updatedQuests.firstWhere((q) => q.id == lessonsQuest.id);
      expect(updatedLessonsQuest.completed, isTrue);
      expect(updatedLessonsQuest.progressValue, lessonsQuest.targetValue);

      final progress = await repo.watchProgress(userId).first;
      final lessonPointsOnly = lessonsQuest.targetValue * (10 + 1);
      expect(progress.points, greaterThanOrEqualTo(lessonPointsOnly + questCompletionBonus));
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

    test('recordMiniGameScore adds points and updates the leaderboard without touching streak',
        () async {
      final repo = FakeProgressRepository();
      await repo.watchProgress(userId).first; // lazily initialize

      await repo.recordMiniGameScore(
        userId: userId,
        userName: 'Ann',
        pointsEarned: 16,
      );

      final progress = await repo.watchProgress(userId).first;
      expect(progress.points, 16);
      expect(progress.streakDays, 0);

      final leaderboard = await repo.watchLeaderboard().first;
      expect(leaderboard.single.name, 'Ann');
      expect(leaderboard.single.points, 16);
    });

    test('recordMiniGameScore increments a pointsEarned quest and awards the bonus on completion',
        () async {
      final repo = FakeProgressRepository();
      final quests = await repo.watchQuests(userId).first;
      final pointsQuests = quests.where((q) => q.type == QuestType.pointsEarned);
      if (pointsQuests.isEmpty) {
        // Unlike lessonsCompleted, a pointsEarned quest isn't guaranteed to be
        // one of this week's 3 active quests — the pool rotates by real
        // calendar week (see quest_templates.dart) and there's no injectable
        // clock to pin it in a test. Skip rather than flake.
        markTestSkipped('no pointsEarned quest active this week');
        return;
      }
      final pointsQuest = pointsQuests.first;

      await repo.recordMiniGameScore(
        userId: userId,
        userName: 'Ann',
        pointsEarned: pointsQuest.targetValue,
      );

      final updatedQuests = await repo.watchQuests(userId).first;
      final updatedPointsQuest = updatedQuests.firstWhere((q) => q.id == pointsQuest.id);
      expect(updatedPointsQuest.completed, isTrue);
      expect(updatedPointsQuest.progressValue, pointsQuest.targetValue);

      // Other quest types must be untouched by a mini-game score.
      final otherQuests = updatedQuests.where((q) => q.type != QuestType.pointsEarned);
      expect(otherQuests.every((q) => q.progressValue == 0 && !q.completed), isTrue);

      final progress = await repo.watchProgress(userId).first;
      expect(progress.points, pointsQuest.targetValue + questCompletionBonus);
    });
  });
}
