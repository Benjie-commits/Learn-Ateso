import 'package:flutter/foundation.dart';

import '../data/repositories/content_repository.dart';
import '../data/repositories/download_repository.dart';
import '../models/lesson_content.dart';
import '../models/level.dart';

class DownloadsProvider extends ChangeNotifier {
  DownloadsProvider(this._contentRepository, this._downloadRepository);

  final ContentRepository _contentRepository;
  final DownloadRepository _downloadRepository;

  bool _isLoaded = false;
  Set<String> _downloadedLevelIds = {};
  final Set<String> _downloadingLevelIds = {};

  Set<String> get downloadedLevelIds => _downloadedLevelIds;
  bool isDownloading(String levelId) => _downloadingLevelIds.contains(levelId);

  Future<void> load() async {
    if (_isLoaded) return;
    _isLoaded = true;
    _downloadedLevelIds = await _downloadRepository.getDownloadedLevelIds();
    notifyListeners();
  }

  Future<void> downloadLevel(Level level) async {
    _downloadingLevelIds.add(level.id);
    notifyListeners();
    try {
      final lessons = await _contentRepository.getLessonsForLevel(level.id);
      final contentByLessonId = <String, LessonContent>{};
      for (final lesson in lessons) {
        contentByLessonId[lesson.id] = await _contentRepository.getLessonContent(lesson.id);
      }
      await _downloadRepository.downloadLevel(
        level: level,
        lessons: lessons,
        contentByLessonId: contentByLessonId,
      );
      _downloadedLevelIds = {..._downloadedLevelIds, level.id};
    } finally {
      _downloadingLevelIds.remove(level.id);
      notifyListeners();
    }
  }

  Future<void> removeDownload(String levelId) async {
    await _downloadRepository.removeDownload(levelId);
    _downloadedLevelIds = {..._downloadedLevelIds}..remove(levelId);
    notifyListeners();
  }
}
