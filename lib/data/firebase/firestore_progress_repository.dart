import 'package:cloud_firestore/cloud_firestore.dart';

import '../../features/quests/quest_templates.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/level_progress.dart';
import '../../models/user_progress.dart';
import '../../models/weekly_quest.dart';
import '../repositories/content_repository.dart';
import '../repositories/progress_repository.dart';
import 'firestore_paths.dart';

class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository(this._contentRepository, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final ContentRepository _contentRepository;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _progressDoc(String userId) =>
      _firestore.doc(FirestorePaths.progressSummary(userId));

  DocumentReference<Map<String, dynamic>> _levelProgressDoc(String userId, String levelId) =>
      _firestore.collection(FirestorePaths.levelProgress(userId)).doc(levelId);

  CollectionReference<Map<String, dynamic>> _questsCollection(String userId) =>
      _firestore.collection(FirestorePaths.quests(userId));

  @override
  Stream<UserProgress> watchProgress(String userId) {
    return _progressDoc(userId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) return UserProgress.empty();
      return UserProgress.fromMap(data);
    });
  }

  @override
  Stream<List<LeaderboardEntry>> watchLeaderboard({int limit = 20}) {
    return _firestore
        .collection(FirestorePaths.leaderboard)
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<List<WeeklyQuest>> _getOrRegenerateQuests(String userId) async {
    final weekStart = weekStartFor(DateTime.now());
    final snapshot = await _questsCollection(userId).get();
    final existing = snapshot.docs.map((doc) => WeeklyQuest.fromMap(doc.id, doc.data())).toList();
    if (existing.isNotEmpty && existing.first.weekStart == weekStart) {
      return existing;
    }
    final fresh = generateWeeklyQuests(weekStart);
    final batch = _firestore.batch();
    for (final quest in fresh) {
      batch.set(_questsCollection(userId).doc(quest.id), quest.toMap());
    }
    await batch.commit();
    return fresh;
  }

  @override
  Stream<List<WeeklyQuest>> watchQuests(String userId) {
    return _questsCollection(userId).snapshots().asyncMap((snapshot) async {
      final weekStart = weekStartFor(DateTime.now());
      final existing = snapshot.docs.map((doc) => WeeklyQuest.fromMap(doc.id, doc.data())).toList();
      if (existing.isNotEmpty && existing.first.weekStart == weekStart) {
        return existing;
      }
      return _getOrRegenerateQuests(userId);
    });
  }

  @override
  Stream<LevelProgress> watchLevelProgress(String userId, String levelId) {
    return _levelProgressDoc(userId, levelId).snapshots().asyncMap((snapshot) async {
      final data = snapshot.data();
      if (data != null) return LevelProgress.fromMap(levelId, data);
      final levels = await _contentRepository.getLevels();
      final level = levels.firstWhere((l) => l.id == levelId);
      return LevelProgress.empty(levelId, unlocked: level.order == 1);
    });
  }

  @override
  Future<LevelProgress> recordLessonCompletion({
    required String userId,
    required String userName,
    required String lessonId,
    required String levelId,
    required int quizScore,
  }) async {
    final lessons = await _contentRepository.getLessonsForLevel(levelId);
    final lessonIndex = lessons.indexWhere((l) => l.id == lessonId);

    final levelDoc = _levelProgressDoc(userId, levelId);
    final existingSnapshot = await levelDoc.get();
    final existing = existingSnapshot.data() != null
        ? LevelProgress.fromMap(levelId, existingSnapshot.data()!)
        : LevelProgress.empty(levelId, unlocked: true);

    final updatedCompleted = {...existing.completedLessonIds, lessonId};
    final updatedPieces = {
      ...existing.revealedPuzzlePositions,
      if (lessonIndex >= 0) lessonIndex,
    };
    final updated = existing.copyWith(
      unlocked: true,
      completedLessonIds: updatedCompleted,
      revealedPuzzlePositions: updatedPieces,
    );
    await levelDoc.set(updated.toMap());

    if (updatedCompleted.length >= lessons.length) {
      final levels = await _contentRepository.getLevels();
      final currentIndex = levels.indexWhere((l) => l.id == levelId);
      if (currentIndex >= 0 && currentIndex + 1 < levels.length) {
        final nextLevel = levels[currentIndex + 1];
        final nextDoc = _levelProgressDoc(userId, nextLevel.id);
        final nextSnapshot = await nextDoc.get();
        final nextUnlocked = nextSnapshot.data()?['unlocked'] as bool? ?? false;
        if (!nextUnlocked) {
          final nextExisting = nextSnapshot.data() != null
              ? LevelProgress.fromMap(nextLevel.id, nextSnapshot.data()!)
              : LevelProgress.empty(nextLevel.id);
          await nextDoc.set(nextExisting.copyWith(unlocked: true).toMap());
        }
      }
    }

    final progressDoc = _progressDoc(userId);
    final progressSnapshot = await progressDoc.get();
    final current = progressSnapshot.data() != null
        ? UserProgress.fromMap(progressSnapshot.data()!)
        : UserProgress.empty();
    final now = DateTime.now();
    final isNewDay = now.difference(current.lastActive).inHours >= 20;
    final streak = isNewDay ? current.streakDays + 1 : current.streakDays;
    final lessonPoints = 10 + quizScore;

    final quests = await _getOrRegenerateQuests(userId);
    var bonusPoints = 0;
    final updatedQuests = quests.map((quest) {
      if (quest.completed) return quest;
      final newProgress = switch (quest.type) {
        QuestType.lessonsCompleted => quest.progressValue + 1,
        QuestType.pointsEarned => quest.progressValue + lessonPoints,
        QuestType.streakMaintained => streak,
      };
      final justCompleted = newProgress >= quest.targetValue;
      if (justCompleted) bonusPoints += questCompletionBonus;
      return quest.copyWith(progressValue: newProgress, completed: justCompleted);
    }).toList();
    final questBatch = _firestore.batch();
    for (final quest in updatedQuests) {
      questBatch.set(_questsCollection(userId).doc(quest.id), quest.toMap());
    }
    await questBatch.commit();

    final newPoints = current.points + lessonPoints + bonusPoints;
    await progressDoc.set(
      current
          .copyWith(
            points: newPoints,
            streakDays: streak,
            lastActive: now,
          )
          .toMap(),
    );
    await _firestore
        .collection(FirestorePaths.leaderboard)
        .doc(userId)
        .set(LeaderboardEntry(userId: userId, name: userName, points: newPoints).toMap());

    return updated;
  }

  @override
  Future<LevelProgress> recordAptitudeTestResult({
    required String userId,
    required String levelId,
    required bool passed,
  }) async {
    final levelDoc = _levelProgressDoc(userId, levelId);
    final snapshot = await levelDoc.get();
    final existing = snapshot.data() != null
        ? LevelProgress.fromMap(levelId, snapshot.data()!)
        : LevelProgress.empty(levelId);
    final updated = existing.copyWith(unlocked: passed);
    await levelDoc.set(updated.toMap());
    return updated;
  }
}
