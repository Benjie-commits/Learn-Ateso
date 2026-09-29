import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/content_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../models/level.dart';
import '../models/level_progress.dart';

/// UI-facing view-model merging shared Level content with this user's
/// LevelProgress. `locked` is derived here, not stored on Level itself —
/// see the note in models/level.dart.
class LevelViewModel {
  LevelViewModel({
    required this.level,
    required this.locked,
    required this.completedLessonIds,
    required this.totalLessonCount,
    required this.revealedPuzzlePositions,
  });

  final Level level;
  final bool locked;
  final Set<String> completedLessonIds;
  final int totalLessonCount;
  final Set<int> revealedPuzzlePositions;

  int get completedLessonCount => completedLessonIds.length;
  int get revealedPuzzlePieces => revealedPuzzlePositions.length;
  bool get isComplete => completedLessonCount >= totalLessonCount && totalLessonCount > 0;
}

class LevelListProvider extends ChangeNotifier {
  LevelListProvider(this._contentRepository, this._progressRepository);

  final ContentRepository _contentRepository;
  final ProgressRepository _progressRepository;

  final List<StreamSubscription<LevelProgress>> _subscriptions = [];
  final Map<String, LevelProgress> _progressByLevel = {};
  final Map<String, int> _lessonCountByLevel = {};

  List<Level> _levels = [];
  bool _isLoading = true;
  String? _userId;

  bool get isLoading => _isLoading;

  List<LevelViewModel> get levelViewModels {
    return _levels.map((level) {
      final progress = _progressByLevel[level.id];
      return LevelViewModel(
        level: level,
        locked: !(progress?.unlocked ?? false),
        completedLessonIds: progress?.completedLessonIds ?? const {},
        totalLessonCount: _lessonCountByLevel[level.id] ?? level.puzzle.totalPieces,
        revealedPuzzlePositions: progress?.revealedPuzzlePositions ?? const {},
      );
    }).toList();
  }

  Future<void> loadForUser(String userId) async {
    if (_userId == userId && _levels.isNotEmpty) return;
    _userId = userId;
    _isLoading = true;
    notifyListeners();

    _levels = await _contentRepository.getLevels();
    for (final level in _levels) {
      final lessons = await _contentRepository.getLessonsForLevel(level.id);
      _lessonCountByLevel[level.id] = lessons.length;
    }

    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    for (final level in _levels) {
      final sub = _progressRepository
          .watchLevelProgress(userId, level.id)
          .listen((progress) {
        _progressByLevel[level.id] = progress;
        notifyListeners();
      });
      _subscriptions.add(sub);
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}
