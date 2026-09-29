import 'dart:async';

import '../../models/lesson.dart';
import '../../models/level_progress.dart';
import '../../models/user_progress.dart';
import '../repositories/progress_repository.dart';
import 'seed_data.dart';

class FakeProgressRepository implements ProgressRepository {
  final Map<String, UserProgress> _progress = {};
  final Map<String, Map<String, LevelProgress>> _levelProgress = {};
  final Map<String, StreamController<UserProgress>> _progressControllers = {};
  final Map<String, StreamController<LevelProgress>> _levelControllers = {};

  String _levelKey(String userId, String levelId) => '$userId:$levelId';

  UserProgress _getOrInitProgress(String userId) {
    return _progress.putIfAbsent(userId, UserProgress.empty);
  }

  LevelProgress _getOrInitLevelProgress(String userId, String levelId) {
    final byLevel = _levelProgress.putIfAbsent(userId, () => {});
    return byLevel.putIfAbsent(levelId, () {
      final level = SeedData.levels.firstWhere((l) => l.id == levelId);
      return LevelProgress.empty(levelId, unlocked: level.order == 1);
    });
  }

  void _emitProgress(String userId, UserProgress progress) {
    _progress[userId] = progress;
    _progressControllers[userId]?.add(progress);
  }

  void _emitLevelProgress(String userId, LevelProgress progress) {
    _levelProgress.putIfAbsent(userId, () => {})[progress.levelId] = progress;
    _levelControllers[_levelKey(userId, progress.levelId)]?.add(progress);
  }

  @override
  Stream<UserProgress> watchProgress(String userId) {
    final controller = _progressControllers.putIfAbsent(
      userId,
      () => StreamController<UserProgress>.broadcast(
        onListen: () {},
      ),
    );
    // Seed the new listener with the current value.
    Future.microtask(() => controller.add(_getOrInitProgress(userId)));
    return controller.stream;
  }

  @override
  Stream<LevelProgress> watchLevelProgress(String userId, String levelId) {
    final key = _levelKey(userId, levelId);
    final controller = _levelControllers.putIfAbsent(
      key,
      () => StreamController<LevelProgress>.broadcast(),
    );
    Future.microtask(
      () => controller.add(_getOrInitLevelProgress(userId, levelId)),
    );
    return controller.stream;
  }

  @override
  Future<LevelProgress> recordLessonCompletion({
    required String userId,
    required String lessonId,
    required String levelId,
    required int quizScore,
  }) async {
    final lessons = SeedData.lessonsByLevel[levelId] ?? const <Lesson>[];
    final lessonIndex = lessons.indexWhere((l) => l.id == lessonId);

    var levelProgress = _getOrInitLevelProgress(userId, levelId);
    final updatedCompleted = {...levelProgress.completedLessonIds, lessonId};
    final updatedPieces = {
      ...levelProgress.revealedPuzzlePositions,
      if (lessonIndex >= 0) lessonIndex,
    };
    levelProgress = levelProgress.copyWith(
      completedLessonIds: updatedCompleted,
      revealedPuzzlePositions: updatedPieces,
    );
    _emitLevelProgress(userId, levelProgress);

    // Auto-unlock the next level once every lesson in this one is complete.
    if (updatedCompleted.length >= lessons.length) {
      final levels = [...SeedData.levels]..sort((a, b) => a.order.compareTo(b.order));
      final currentIndex = levels.indexWhere((l) => l.id == levelId);
      if (currentIndex >= 0 && currentIndex + 1 < levels.length) {
        final nextLevel = levels[currentIndex + 1];
        final nextProgress = _getOrInitLevelProgress(userId, nextLevel.id);
        if (!nextProgress.unlocked) {
          _emitLevelProgress(userId, nextProgress.copyWith(unlocked: true));
        }
      }
    }

    final current = _getOrInitProgress(userId);
    final points = current.points + 10 + quizScore;
    final lastActive = current.lastActive;
    final now = DateTime.now();
    final isNewDay = now.difference(lastActive).inHours >= 20;
    final streak = isNewDay ? current.streakDays + 1 : current.streakDays;
    _emitProgress(
      userId,
      current.copyWith(points: points, streakDays: streak, lastActive: now),
    );

    return levelProgress;
  }

  @override
  Future<LevelProgress> recordAptitudeTestResult({
    required String userId,
    required String levelId,
    required bool passed,
  }) async {
    final levelProgress = _getOrInitLevelProgress(userId, levelId);
    final updated = levelProgress.copyWith(unlocked: passed);
    _emitLevelProgress(userId, updated);
    return updated;
  }
}
