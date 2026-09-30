/// Centralizes Firestore collection/document paths so the schema is defined
/// in exactly one place. Mirrors the fake repositories' seeded structure
/// (see data/fake/seed_data.dart) so behavior stays identical across both
/// backends.
class FirestorePaths {
  FirestorePaths._();

  static const levels = 'levels';
  static String lessonsForLevel(String levelId) => 'levels/$levelId/lessons';
  static const lessonContent = 'content_lessons';
  static const aptitudeTests = 'aptitudeTests';
  static const users = 'users';
  static const leaderboard = 'leaderboard';
  static String progressSummary(String userId) => 'users/$userId/progress/summary';
  static String levelProgress(String userId) => 'users/$userId/levelProgress';
}
