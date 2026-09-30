import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_ateso/data/firebase/firestore_content_repository.dart';
import 'package:learn_ateso/data/firebase/firestore_progress_repository.dart';
import 'package:learn_ateso/data/firebase/firestore_paths.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreContentRepository contentRepo;
  late FirestoreProgressRepository progressRepo;
  const userId = 'user-1';

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    contentRepo = FirestoreContentRepository(firestore: firestore);
    progressRepo = FirestoreProgressRepository(contentRepo, firestore: firestore);

    await firestore.collection(FirestorePaths.levels).doc('level_1').set({
      'name': 'Level 1',
      'order': 1,
      'puzzle': {'totalPieces': 2},
    });
    await firestore.collection(FirestorePaths.levels).doc('level_2').set({
      'name': 'Level 2',
      'order': 2,
      'puzzle': {'totalPieces': 2},
    });
    await firestore
        .collection(FirestorePaths.lessonsForLevel('level_1'))
        .doc('lesson_1_1')
        .set({'title': 'Lesson 1', 'order': 1});
    await firestore
        .collection(FirestorePaths.lessonsForLevel('level_1'))
        .doc('lesson_1_2')
        .set({'title': 'Lesson 2', 'order': 2});
  });

  group('FirestoreProgressRepository', () {
    test('level_1 defaults unlocked, level_2 does not', () async {
      final level1 = await progressRepo.watchLevelProgress(userId, 'level_1').first;
      final level2 = await progressRepo.watchLevelProgress(userId, 'level_2').first;

      expect(level1.unlocked, isTrue);
      expect(level2.unlocked, isFalse);
    });

    test('completing a lesson reveals a puzzle piece and awards points', () async {
      final result = await progressRepo.recordLessonCompletion(
        userId: userId,
        userName: 'Ann',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 2,
      );

      expect(result.completedLessonIds, contains('lesson_1_1'));
      expect(result.revealedPuzzlePositions, isNotEmpty);

      final progress = await progressRepo.watchProgress(userId).first;
      expect(progress.points, greaterThan(0));
    });

    test('completing every lesson in a level auto-unlocks the next level', () async {
      await progressRepo.recordLessonCompletion(
        userId: userId,
        userName: 'Ann',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 2,
      );
      await progressRepo.recordLessonCompletion(
        userId: userId,
        userName: 'Ann',
        lessonId: 'lesson_1_2',
        levelId: 'level_1',
        quizScore: 2,
      );

      final level2 = await progressRepo.watchLevelProgress(userId, 'level_2').first;
      expect(level2.unlocked, isTrue);
    });

    test('recordLessonCompletion writes a leaderboard entry queryable by points', () async {
      await progressRepo.recordLessonCompletion(
        userId: 'user-1',
        userName: 'Ann',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 1,
      );
      await progressRepo.recordLessonCompletion(
        userId: 'user-2',
        userName: 'Ben',
        lessonId: 'lesson_1_1',
        levelId: 'level_1',
        quizScore: 5,
      );

      final leaderboard = await progressRepo.watchLeaderboard().first;

      expect(leaderboard.first.name, 'Ben');
      expect(leaderboard.first.points, greaterThan(leaderboard.last.points));
    });

    test('passing the aptitude test unlocks the level directly', () async {
      final result = await progressRepo.recordAptitudeTestResult(
        userId: userId,
        levelId: 'level_2',
        passed: true,
      );

      expect(result.unlocked, isTrue);
      expect(result.completedLessonIds, isEmpty);
    });

    test('failing the aptitude test keeps the level locked', () async {
      final result = await progressRepo.recordAptitudeTestResult(
        userId: userId,
        levelId: 'level_2',
        passed: false,
      );

      expect(result.unlocked, isFalse);
    });
  });
}
