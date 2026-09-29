import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/aptitude_test.dart';
import '../../models/lesson.dart';
import '../../models/lesson_content.dart';
import '../../models/level.dart';
import '../repositories/content_repository.dart';
import 'firestore_paths.dart';

class FirestoreContentRepository implements ContentRepository {
  FirestoreContentRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<List<Level>> getLevels() async {
    final snapshot =
        await _firestore.collection(FirestorePaths.levels).orderBy('order').get();
    return snapshot.docs.map((doc) => Level.fromMap(doc.id, doc.data())).toList();
  }

  @override
  Future<List<Lesson>> getLessonsForLevel(String levelId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.lessonsForLevel(levelId))
        .orderBy('order')
        .get();
    return snapshot.docs
        .map((doc) => Lesson.fromMap(doc.id, levelId, doc.data()))
        .toList();
  }

  @override
  Future<LessonContent> getLessonContent(String lessonId) async {
    final doc = await _firestore
        .collection(FirestorePaths.lessonContent)
        .doc(lessonId)
        .get();
    final data = doc.data();
    if (data == null) {
      throw StateError('No content found for lesson $lessonId');
    }
    return LessonContent.fromMap(lessonId, data);
  }

  @override
  Future<AptitudeTest> getAptitudeTest(String levelId) async {
    final doc = await _firestore
        .collection(FirestorePaths.aptitudeTests)
        .doc(levelId)
        .get();
    final data = doc.data();
    if (data == null) {
      throw StateError('No aptitude test found for level $levelId');
    }
    return AptitudeTest.fromMap(levelId, data);
  }
}
