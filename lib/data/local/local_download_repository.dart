import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/lesson.dart';
import '../../models/lesson_content.dart';
import '../../models/level.dart';
import '../repositories/download_repository.dart';

class LocalDownloadRepository implements DownloadRepository {
  static const _levelIdsKey = 'download_level_ids';

  String _lessonsKey(String levelId) => 'download_lessons_$levelId';
  String _contentKey(String lessonId) => 'download_content_$lessonId';

  @override
  Future<Set<String>> getDownloadedLevelIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_levelIdsKey) ?? const []).toSet();
  }

  @override
  Future<void> downloadLevel({
    required Level level,
    required List<Lesson> lessons,
    required Map<String, LessonContent> contentByLessonId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _lessonsKey(level.id),
      jsonEncode(lessons.map((l) => {'id': l.id, ...l.toMap()}).toList()),
    );
    for (final entry in contentByLessonId.entries) {
      await prefs.setString(_contentKey(entry.key), jsonEncode(entry.value.toMap()));
    }

    final levelIds = (prefs.getStringList(_levelIdsKey) ?? const []).toSet()..add(level.id);
    await prefs.setStringList(_levelIdsKey, levelIds.toList());
  }

  @override
  Future<void> removeDownload(String levelId) async {
    final prefs = await SharedPreferences.getInstance();

    final cachedLessons = await getCachedLessons(levelId);
    if (cachedLessons != null) {
      for (final lesson in cachedLessons) {
        await prefs.remove(_contentKey(lesson.id));
      }
    }
    await prefs.remove(_lessonsKey(levelId));

    final levelIds = (prefs.getStringList(_levelIdsKey) ?? const []).toSet()..remove(levelId);
    await prefs.setStringList(_levelIdsKey, levelIds.toList());
  }

  @override
  Future<List<Lesson>?> getCachedLessons(String levelId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lessonsKey(levelId));
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((m) => Lesson.fromMap(m['id'] as String, levelId, Map<String, dynamic>.from(m as Map)))
        .toList();
  }

  @override
  Future<LessonContent?> getCachedLessonContent(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contentKey(lessonId));
    if (raw == null) return null;
    return LessonContent.fromMap(lessonId, Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }
}
