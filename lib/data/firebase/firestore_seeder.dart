import 'package:cloud_firestore/cloud_firestore.dart';

import '../fake/seed_data.dart';
import 'firestore_paths.dart';

/// Pushes the placeholder content from data/fake/seed_data.dart into
/// Firestore. Debug-only — see the "Seed placeholder content" action gated
/// by kDebugMode in the settings stub screen. Runs inside the app (not a
/// standalone script) because cloud_firestore needs platform-channel
/// registration that only exists once the Flutter engine is running.
class FirestoreSeeder {
  FirestoreSeeder({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> run() async {
    final batch = _firestore.batch();

    for (final level in SeedData.levels) {
      batch.set(
        _firestore.collection(FirestorePaths.levels).doc(level.id),
        level.toMap(),
      );
    }

    for (final entry in SeedData.lessonsByLevel.entries) {
      for (final lesson in entry.value) {
        batch.set(
          _firestore
              .collection(FirestorePaths.lessonsForLevel(entry.key))
              .doc(lesson.id),
          lesson.toMap(),
        );
      }
    }

    for (final entry in SeedData.lessonContent.entries) {
      batch.set(
        _firestore.collection(FirestorePaths.lessonContent).doc(entry.key),
        entry.value.toMap(),
      );
    }

    for (final entry in SeedData.aptitudeTests.entries) {
      batch.set(
        _firestore.collection(FirestorePaths.aptitudeTests).doc(entry.key),
        entry.value.toMap(),
      );
    }

    await batch.commit();
  }
}
